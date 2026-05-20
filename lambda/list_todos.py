"""
Lambda function: GET /todos
Returns all todos for the authenticated user.
"""

from common import table, get_user_id, success_response, error_response
from boto3.dynamodb.conditions import Key

def handler(event, context):
    """
    Main Lambda handler function.
    AWS calls this when GET /todos is requested.

    Args:
        event: Contains request data (headers, path, body, etc.)
        context: Runtime information about the Lambda

    Returns:
        HTTP response with list of todos
    """
    try:
        # Get user ID from request
        user_id = get_user_id(event)

        # Query DynamoDB for all todos belonging to this user
        # Query is efficient because we use userId as partition key
        response = table.query(
            KeyConditionExpression=Key('userId').eq(user_id)
        )

        # Extract items from response
        todos = response.get('Items', [])

        # Sort by createdAt (newest first)
        todos.sort(key=lambda x: x.get('createdAt', 0), reverse=True)

        # Return success with todos
        return success_response(200, {'todos': todos})

    except Exception as e:
        # If anything goes wrong, return error
        print(f"Error listing todos: {str(e)}")
        return error_response(500, 'Failed to list todos')
