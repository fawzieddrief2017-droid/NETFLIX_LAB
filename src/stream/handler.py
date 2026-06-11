import json
import os
import time
import boto3
import rsa
from base64 import b64encode

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TITLES_TABLE', 'Titles')
table = dynamodb.Table(table_name)

CF_DOMAIN = os.environ.get('CLOUDFRONT_DOMAIN', '')
KEY_PAIR_ID = os.environ.get('KEY_PAIR_ID', '')
# Read private key from environment or secrets manager (for lab, env is fine if short)
# In Terraform we'll inject the private key as an env var for simplicity in this lab
PRIVATE_KEY_STR = os.environ.get('PRIVATE_KEY', '').replace('\\n', '\n')

def get_cors_headers():
    return {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type,Authorization',
        'Access-Control-Allow-Methods': 'OPTIONS,GET'
    }

def build_response(status_code, body):
    return {
        'statusCode': status_code,
        'headers': get_cors_headers(),
        'body': json.dumps(body)
    }

def sign_url(url, key_id, private_key_string, expire_time):
    # Construct policy
    policy = {
        "Statement": [
            {
                "Resource": url,
                "Condition": {
                    "DateLessThan": {"AWS:EpochTime": int(expire_time)}
                }
            }
        ]
    }
    policy_json = json.dumps(policy, separators=(',', ':')).encode('utf-8')
    
    # URL safe base64
    def url_base64(data):
        return b64encode(data).replace(b'+', b'-').replace(b'=', b'_').replace(b'/', b'~').decode('utf-8')
    
    # Load RSA private key and sign
    priv_key = rsa.PrivateKey.load_pkcs1(private_key_string.encode('utf-8'))
    signature = rsa.sign(policy_json, priv_key, 'SHA-1')
    
    signed_url = f"{url}?Expires={int(expire_time)}&Signature={url_base64(signature)}&Key-Pair-Id={key_id}"
    return signed_url

def handler(event, context):
    try:
        route_key = event.get('routeKey', '')
        path_parameters = event.get('pathParameters', {})

        if route_key == 'GET /titles/{id}/stream':
            title_id = path_parameters.get('id')
            if not title_id:
                return build_response(400, {'message': 'Missing title ID'})

            # Get title to find videoKey
            response = table.get_item(Key={'titleId': title_id})
            item = response.get('Item')
            
            if not item or 'videoKey' not in item:
                return build_response(404, {'message': 'Video not found for title'})
                
            video_key = item['videoKey']
            
            # Generate signed URL
            expire_time = int(time.time()) + 3600 # 1 hour expiry
            # Ensure domain doesn't have trailing slash
            domain = CF_DOMAIN.rstrip('/')
            url = f"https://{domain}/{video_key}"
            
            try:
                signed_url = sign_url(url, KEY_PAIR_ID, PRIVATE_KEY_STR, expire_time)
                return build_response(200, {'streamUrl': signed_url})
            except Exception as e:
                print(f"Signing error: {str(e)}")
                return build_response(500, {'message': 'Failed to generate secure URL'})

        return build_response(404, {'message': 'Not Found'})

    except Exception as e:
        print(f"Error: {str(e)}")
        return build_response(500, {'message': 'Internal server error'})
