import boto3
import os

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('ucr-todos')

# Scan all todos
response = table.scan()
todos = response['Items']

print(f"Found {len(todos)} todos to migrate...")

for todo in todos:
    title = todo.get('title', '')
    
    # Determine category based on title
    if 'VACATION' in title or any(word in title.lower() for word in ['japan', 'europe', 'canyon', 'iceland', 'beach', 'trip']):
        category = 'Vacation'
    elif 'LIFE GOALS' in title or any(word in title.lower() for word in ['marathon', 'piano', 'books', 'cooking', 'japanese', 'investment', 'countries']):
        category = 'Life Goals'
    elif any(word in title.lower() for word in ['grocery', 'shopping']):
        category = 'Shopping'
    elif any(word in title.lower() for word in ['gym', 'fitness']):
        category = 'Health'
    elif any(word in title.lower() for word in ['applications', 'work']):
        category = 'Work'
    else:
        category = 'General'
    
    # Remove folder prefixes from title if present
    clean_title = title.replace('📁 VACATION/', '').replace('🎯 LIFE GOALS/', '')
    
    # Update the item
    table.update_item(
        Key={
            'userId': todo['userId'],
            'sortKey': todo['sortKey']
        },
        UpdateExpression='SET category = :cat, title = :title',
        ExpressionAttributeValues={
            ':cat': category,
            ':title': clean_title
        }
    )
    print(f"✓ Updated: {clean_title[:50]}... → {category}")

print("\n✅ Migration complete!")
