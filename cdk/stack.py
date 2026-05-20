"""
CDK Stack Definition

This file defines all AWS resources:
- DynamoDB table for storing todos
- 4 Lambda functions (list, create, toggle, delete)
- API Gateway to expose HTTP endpoints
- IAM permissions (least privilege)
"""

from aws_cdk import (
    Stack,
    aws_dynamodb as dynamodb,
    aws_lambda as lambda_,
    aws_iam as iam,
    CfnOutput,
    RemovalPolicy,
    Duration
)
from constructs import Construct
from aws_cdk.aws_apigatewayv2_alpha import (
    HttpApi,
    CorsPreflightOptions,
    CorsHttpMethod,
    HttpMethod
)
from aws_cdk.aws_apigatewayv2_integrations_alpha import HttpLambdaIntegration

class TodoCapstoneStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # ===================================================================
        # 1. CREATE DYNAMODB TABLE
        # ===================================================================
        table = dynamodb.Table(
            self, "TodosTable",
            table_name="ucr-todos",
            partition_key=dynamodb.Attribute(
                name="userId",
                type=dynamodb.AttributeType.STRING
            ),
            sort_key=dynamodb.Attribute(
                name="sortKey",
                type=dynamodb.AttributeType.STRING
            ),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST,  # Auto-scaling
            removal_policy=RemovalPolicy.DESTROY,  # Delete table when stack is deleted (demo only!)
        )

        # ===================================================================
        # 2. CREATE LAMBDA EXECUTION ROLE (IAM)
        # ===================================================================
        lambda_role = iam.Role(
            self, "TodoLambdaRole",
            assumed_by=iam.ServicePrincipal("lambda.amazonaws.com"),
            managed_policies=[
                # Allows Lambda to write logs to CloudWatch
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "service-role/AWSLambdaBasicExecutionRole"
                )
            ]
        )

        # Grant specific DynamoDB permissions to Lambda (least privilege)
        table.grant_read_write_data(lambda_role)

        # ===================================================================
        # 3. CREATE LAMBDA FUNCTIONS
        # ===================================================================

        # Common Lambda configuration
        lambda_config = {
            "runtime": lambda_.Runtime.PYTHON_3_9,
            "timeout": Duration.seconds(10),
            "role": lambda_role,
            "environment": {
                "TABLE_NAME": table.table_name
            }
        }

        # List todos function
        list_fn = lambda_.Function(
            self, "ListTodosFunction",
            function_name="ucr-list-todos",
            code=lambda_.Code.from_asset("../lambda"),
            handler="list_todos.handler",
            **lambda_config
        )

        # Create todo function
        create_fn = lambda_.Function(
            self, "CreateTodoFunction",
            function_name="ucr-create-todo",
            code=lambda_.Code.from_asset("../lambda"),
            handler="create_todo.handler",
            **lambda_config
        )

        # Toggle todo function
        toggle_fn = lambda_.Function(
            self, "ToggleTodoFunction",
            function_name="ucr-toggle-todo",
            code=lambda_.Code.from_asset("../lambda"),
            handler="toggle_todo.handler",
            **lambda_config
        )

        # Delete todo function
        delete_fn = lambda_.Function(
            self, "DeleteTodoFunction",
            function_name="ucr-delete-todo",
            code=lambda_.Code.from_asset("../lambda"),
            handler="delete_todo.handler",
            **lambda_config
        )

        # ===================================================================
        # 4. CREATE API GATEWAY (HTTP API)
        # ===================================================================

        # Create HTTP API (cheaper and faster than REST API)
        api = HttpApi(
            self, "TodoApi",
            api_name="ucr-todo-api",
            cors_preflight=CorsPreflightOptions(
                allow_origins=["*"],  # Allow all origins (production: specific domain)
                allow_methods=[
                    CorsHttpMethod.GET,
                    CorsHttpMethod.POST,
                    CorsHttpMethod.PATCH,
                    CorsHttpMethod.DELETE,
                    CorsHttpMethod.OPTIONS
                ],
                allow_headers=["Content-Type", "X-User-Id"],
                max_age=Duration.days(1)
            )
        )

        # ===================================================================
        # 5. CREATE API ROUTES (Connect URLs to Lambda functions)
        # ===================================================================

        # GET /todos -> list_fn
        api.add_routes(
            path="/todos",
            methods=[HttpMethod.GET],
            integration=HttpLambdaIntegration(
                "ListTodosIntegration",
                list_fn
            )
        )

        # POST /todos -> create_fn
        api.add_routes(
            path="/todos",
            methods=[HttpMethod.POST],
            integration=HttpLambdaIntegration(
                "CreateTodoIntegration",
                create_fn
            )
        )

        # PATCH /todos/{id} -> toggle_fn
        api.add_routes(
            path="/todos/{id}",
            methods=[HttpMethod.PATCH],
            integration=HttpLambdaIntegration(
                "ToggleTodoIntegration",
                toggle_fn
            )
        )

        # DELETE /todos/{id} -> delete_fn
        api.add_routes(
            path="/todos/{id}",
            methods=[HttpMethod.DELETE],
            integration=HttpLambdaIntegration(
                "DeleteTodoIntegration",
                delete_fn
            )
        )

        # ===================================================================
        # 6. OUTPUTS (Display after deployment)
        # ===================================================================

        CfnOutput(
            self, "ApiUrl",
            value=api.url or "API URL will be available after deployment",
            description="Todo API Gateway URL - use this in Flutter app"
        )

        CfnOutput(
            self, "TableName",
            value=table.table_name,
            description="DynamoDB table name"
        )
