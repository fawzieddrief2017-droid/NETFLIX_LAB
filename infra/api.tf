resource "aws_apigatewayv2_api" "main" {
  name          = "${var.project_prefix}-api"
  protocol_type = "HTTP"
  
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.main.id]
    issuer   = "https://${aws_cognito_user_pool.main.endpoint}"
  }
}

# --- Integrations ---
resource "aws_apigatewayv2_integration" "catalog" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  
  integration_method = "POST"
  integration_uri    = aws_lambda_function.catalog.invoke_arn
}

resource "aws_apigatewayv2_integration" "stream" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  
  integration_method = "POST"
  integration_uri    = aws_lambda_function.stream.invoke_arn
}

resource "aws_apigatewayv2_integration" "history" {
  api_id           = aws_apigatewayv2_api.main.id
  integration_type = "AWS_PROXY"
  
  integration_method = "POST"
  integration_uri    = aws_lambda_function.history.invoke_arn
}

# --- Routes ---
resource "aws_apigatewayv2_route" "get_titles" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /titles"
  target             = "integrations/${aws_apigatewayv2_integration.catalog.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_title" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /titles/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.catalog.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_stream" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /titles/{id}/stream"
  target             = "integrations/${aws_apigatewayv2_integration.stream.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get_history" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "GET /users/{userId}/history/{titleId}"
  target             = "integrations/${aws_apigatewayv2_integration.history.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "post_history" {
  api_id             = aws_apigatewayv2_api.main.id
  route_key          = "POST /users/{userId}/history"
  target             = "integrations/${aws_apigatewayv2_integration.history.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# --- Lambda Permissions ---
resource "aws_lambda_permission" "apigw_catalog" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.catalog.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_stream" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.stream.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_history" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
