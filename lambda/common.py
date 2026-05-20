"""
Common utilities shared across all Lambda functions.
This file sets up the DynamoDB connection that all functions will use.
"""

import boto3
import os
import json
from decimal import Decimal

# Get the table name from environment variable (set by CDK)
TABLE_NAME = os.environ.get('TABLE_NAME', 'ucr-todos')

# Create DynamoDB resource - this connects to AWS database
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def get_user_id(event):
    """
    Extract user ID from the request headers.
    In production, this would come from Cognito JWT token.
    For demo, we use a simple header: x-user-id
    """
    headers = event.get('headers', {})
    # Headers might be lowercase or Title-Case, handle both
    user_id = headers.get('x-user-id') or headers.get('X-User-Id') or 'default-user'
    return user_id

def cors_headers():
    """
    CORS headers allow the Flutter web app (running on different domain)
    to call our API. Without these, browser blocks the requests.
    """
    return {
        'Access-Control-Allow-Origin': '*',  # Allow any website (production: use specific domain)
        'Access-Control-Allow-Headers': 'Content-Type,X-User-Id',
        'Access-Control-Allow-Methods': 'GET,POST,PATCH,DELETE,OPTIONS'
    }

class DecimalEncoder(json.JSONEncoder):
    """Convert Decimal objects to int/float for JSON serialization"""
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super(DecimalEncoder, self).default(obj)

def success_response(status_code, body):
    """Helper to return successful response with CORS headers"""
    return {
        'statusCode': status_code,
        'headers': cors_headers(),
        'body': json.dumps(body, cls=DecimalEncoder)
    }

def error_response(status_code, message):
    """Helper to return error response with CORS headers"""
    return {
        'statusCode': status_code,
        'headers': cors_headers(),
        'body': json.dumps({'error': message}, cls=DecimalEncoder)
    }
