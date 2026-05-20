#!/usr/bin/env python3
"""
CDK App Entry Point

This is the main file that AWS CDK runs.
It creates and deploys the entire stack to AWS.
"""

import aws_cdk as cdk
from stack import TodoCapstoneStack

# Create the CDK app
app = cdk.App()

# Create our stack with a unique name (using initials: ucr)
TodoCapstoneStack(
    app,
    "ucr-todo-capstone-stack",  # Stack name in AWS CloudFormation
    description="Todo app capstone project - DynamoDB + Lambda + API Gateway",
    env=cdk.Environment(
        account="425680120934",  # Your AWS account ID
        region="us-east-1"       # AWS region
    )
)

# Synthesize CloudFormation template
app.synth()
