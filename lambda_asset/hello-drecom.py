from datetime import datetime
from pytz import timezone
import json

def lambda_handler(event, context):
    jst = datetime.now(timezone('Asia/Tokyo')).strftime('%Y-%m-%dT%H:%M:%S%z')
    message = '{} <{}>'.format("with entertainment", jst)
    return {
        'isBase64Encoded': False,
        'statusCode': 200,
        'headers': {},
        'body': json.dumps({
            'drecom' : message
        })
    }