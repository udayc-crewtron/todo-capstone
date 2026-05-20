"""
Lambda function: PATCH /todos/{id}
Toggles a todo between done and not done.
"""

import json
from common import table, get_user_id, success_response, error_response
from boto3.dynamodb.conditions import Key

def handler(event, context):
    """
    Toggles the 'done' status of a todo.

    URL: PATCH /todos/{todoId}
    Body:
    {
        "done": true
    }
    """
    try:
        # Get user ID and todo ID
        user_id = get_user_id(event)
        todo_id = event['pathParameters']['id']

        # First, find the todo to get its sort key and current state
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
        current_done = todo.get('done', False)

        # Toggle the done status
        new_done = not current_done

        # Update the todo
        table.update_item(
            Key={
                'userId': user_id,
                'sortKey': sort_key
            },
            UpdateExpression='SET done = :done',
            ExpressionAttributeValues={':done': new_done}
        )

        # Return updated todo
        todo['done'] = new_done
        return success_response(200, {'todo': todo})

    except json.JSONDecodeError:
        return error_response(400, 'Invalid JSON in request body')
    except KeyError as e:
        return error_response(400, f'Missing required field: {str(e)}')
    except Exception as e:
        print(f"Error toggling todo: {str(e)}")
        return error_response(500, 'Failed to toggle todo')
