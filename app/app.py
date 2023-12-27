import os
import boto3
import json

# Configuration - Use environment variables
S3_BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')
S3_JSON_FILE_NAME = os.environ.get('S3_JSON_FILE_NAME')

def lambda_handler(event, context):
    s3 = boto3.client('s3')

    try:
        response = s3.get_object(Bucket=S3_BUCKET_NAME, Key=S3_JSON_FILE_NAME)
        content = response['Body'].read()
        # Decode the bytes content into a string (assuming it's in UTF-8 format)
        content_str = content.decode('utf-8')
        # Convert the string to a Python dictionary or list using json.loads()
        content_json = json.loads(content_str)
        return {
            'statusCode': 200,
            'body': json.dumps(content_json)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({"error": str(e)})
        }
