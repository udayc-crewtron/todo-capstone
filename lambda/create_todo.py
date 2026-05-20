"""
Lambda function: POST /todos
Creates a new todo for the authenticated user.
"""

import json
import uuid
import time
from common import table, get_user_id, success_response, error_response

def handler(event, context):
    """
    Creates a new todo item.

    Expected request body:
    {
        "title": "Buy groceries"
    }

    Returns the created todo.
    """
    try:
        # Get user ID from request
        user_id = get_user_id(event)

        # Parse request body (JSON string → Python dict)
        body = json.loads(event.get('body', '{}'))
        title = body.get('title', '').strip()
        category = body.get('category', 'General').strip()  # Default to 'General'
        deadline = body.get('deadline')  # Optional deadline timestamp

        # Validate input
        if not title:
            return error_response(400, 'Title is required')

        # Generate unique ID and timestamp
        todo_id = str(uuid.uuid4())
        created_at = int(time.time() * 1000)  # Unix timestamp in milliseconds

        # Create todo item
        todo = {
            'userId': user_id,  # Partition key
            'sortKey': f"{created_at}#{todo_id}",  # Sort key (timestamp + ID)
            'todoId': todo_id,
            'title': title,
            'done': False,
            'category': category,  # Add category field
            'createdAt': created_at
        }

        # Add deadline if provided
        if deadline:
            todo['deadline'] = deadline

        # Save to DynamoDB
        table.put_item(Item=todo)

        # Return the created todo
        return success_response(201, {'todo': todo})

    except json.JSONDecodeError:
        return error_response(400, 'Invalid JSON in request body')
    except Exception as e:
        print(f"Error creating todo: {str(e)}")
        return error_response(500, 'Failed to create todo')
