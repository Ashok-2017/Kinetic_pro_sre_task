resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  authorization = var.authorization
  request_validator_id = var.request_validator_id
  request_models = var.request_models
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  timeout_milliseconds = var.timeout_milliseconds
  uri = var.uri
  depends_on = [aws_api_gateway_method.method]
}


resource "aws_api_gateway_method_response" "response_202" {
  count = var.response202 ? 1 : 0
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "202"
  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_method_response" "response_200" {
  count = var.response200 ? 1 : 0
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "200"
  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_gateway_response" "response_400" {
  count = var.response400 ? 1 : 0
  rest_api_id = var.rest_api_id
  status_code = "400"
    response_type = "BAD_REQUEST_BODY"

  response_templates = {
    "application/json" = "{\"message\":\"$context.error.validationErrorString\"}"
  }
  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_gateway_response" "response_401" {
  count = var.response401 ? 1 : 0
  rest_api_id = var.rest_api_id
  status_code = "401"
    response_type = "UNAUTHORIZED"

  response_templates = {
    "application/json" = "{\"message\":\"$context.error.validationErrorString\"}"
"main.tf" 76L, 2308B

