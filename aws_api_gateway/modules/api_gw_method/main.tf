resource "aws_api_gateway_method" "method" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  authorization = var.authorization
}


resource "aws_api_gateway_integration" "hello0" {
  rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  timeout_milliseconds = var.timeout_milliseconds
  uri = var.uri
  depends_on = [aws_api_gateway_method.method]
}


resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = var.rest_api_id
  resource_id = var.resource_id
  http_method = var.http_method
  status_code = "200"
  depends_on = [aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_integration" "hello1" {

rest_api_id   = var.rest_api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  integration_http_method = "POST"
  type                 = "AWS_PROXY"
  timeout_milliseconds = var.timeout_milliseconds
  uri = var.uri
  depends_on = [aws_api_gateway_method.method]
}



