"""
Lambda function: DELETE /todos/{id}
Deletes a todo.
"""

from common import table, get_user_id, success_response, error_response
from boto3.dynamodb.conditions import Key

def handler(event, context):
    """
    Deletes a todo item.

    URL: DELETE /todos/{todoId}
    """
    try:
        # Get user ID and todo ID
        user_id = get_user_id(event)
        todo_id = event['pathParameters']['id']

        # First, find the todo to get its sort key
        response = table.query(
            KeyConditionExpression=Key('userId').eq(user_id),
            FilterExpression='todoId = :tid',
            ExpressionAttributeValues={':tid': todo_id}
        )

        items = response.get('Items', [])
        if not items:
            return error_response(404, 'Todo not found')

        todo = items[0]
        sort_key = todo['sortKey']

        # Delete the todo
        table.delete_item(
            Key={
                'userId': user_id,
                'sortKey': sort_key
            }
        )

        # Return success
        return success_response(200, {'message': 'Todo deleted successfully'})

    except KeyError as e:
        return error_response(400, f'Missing required field: {str(e)}')
    except Exception as e:
        print(f"Error deleting todo: {str(e)}")
        return error_response(500, 'Failed to delete todo')
