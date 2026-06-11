import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('TITLES_TABLE', 'Titles')
table = dynamodb.Table(table_name)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

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
        'body': json.dumps(body, cls=DecimalEncoder)
    }

def handler(event, context):
    try:
        route_key = event.get('routeKey', '')
        path_parameters = event.get('pathParameters', {})

        if route_key == 'GET /titles':
            # Scan is acceptable for <10 items lab scale
            response = table.scan()
            items = response.get('Items', [])
            return build_response(200, items)

        elif route_key == 'GET /titles/{id}':
            title_id = path_parameters.get('id')
            if not title_id:
                return build_response(400, {'message': 'Missing title ID'})

            response = table.get_item(Key={'titleId': title_id})
            item = response.get('Item')
            
            if not item:
                return build_response(404, {'message': 'Title not found'})
                
            return build_response(200, item)

        return build_response(404, {'message': 'Not Found'})

    except Exception as e:
        print(f"Error: {str(e)}")
        return build_response(500, {'message': 'Internal server error'})
