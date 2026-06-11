import json
import os
import boto3
from datetime import datetime, timezone
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('HISTORY_TABLE', 'WatchHistory')
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
        'Access-Control-Allow-Methods': 'OPTIONS,GET,POST'
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
        
        user_id = path_parameters.get('userId')
        
        # Security Note: In a real environment, we'd verify userId matches the JWT claims
        # from event.requestContext.authorizer.jwt.claims.sub
        
        if not user_id:
            return build_response(400, {'message': 'Missing user ID'})

        if route_key == 'GET /users/{userId}/history/{titleId}':
            title_id = path_parameters.get('titleId')
            if not title_id:
                return build_response(400, {'message': 'Missing title ID'})

            response = table.get_item(Key={'userId': user_id, 'titleId': title_id})
            item = response.get('Item')
            
            if not item:
                # Return default zero state if no history
                return build_response(200, {'lastTimestamp': 0, 'completed': False})
                
            return build_response(200, item)

        elif route_key == 'POST /users/{userId}/history':
            body = {}
            if event.get('body'):
                body = json.loads(event['body'])
            
            title_id = body.get('titleId')
            last_timestamp = body.get('lastTimestamp', 0)
            completed = body.get('completed', False)
            
            if not title_id:
                return build_response(400, {'message': 'Missing titleId in body'})
                
            item = {
                'userId': user_id,
                'titleId': title_id,
                'lastTimestamp': Decimal(str(last_timestamp)),
                'lastUpdated': datetime.now(timezone.utc).isoformat(),
                'completed': completed
            }
            
            table.put_item(Item=item)
            return build_response(200, {'message': 'History updated successfully'})

        return build_response(404, {'message': 'Not Found'})

    except Exception as e:
        print(f"Error: {str(e)}")
        return build_response(500, {'message': 'Internal server error'})
