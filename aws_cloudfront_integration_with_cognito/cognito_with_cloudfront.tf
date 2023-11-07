provider "aws" {
  region = "us-east-1" 
}

# Define an AWS Cognito User Pool ID (replace with your actual User Pool ID)

variable "cognito_user_pool_id" { }

resource "aws_cloudfront_distribution" "my_distribution" {
  origin {
    domain_name = "my-bucket.s3.amazonaws.com"
    origin_id = "my-origin"
 }

enabled = true

# Configure AWS Cognito authentication behavior

default_cache_behaviour	{
  viewer_protocol_policy = "redirect-to-https"
}

lambda_function_association {
  event_type = "viewer-request"
  lambda_arn = "arn:aws:<your-region>:<your-account-id>:function/my-cognito-auth-function"
}

}

restrictions {
  geo_restriction {
    restriction_type = "none" 
  }
 }

viewer_certificate {
  cloudfront_default_certificate = true 

}

}

# Define an AWS Lambda function to authenticate with AWS Cognito

resource "aws_lambda_function" "cognito_auth_function" {
  filename = "auth.zip"
  function_name = "my-cognito-auth-function"
  handler = "index.handler"
  role = aws_iam_role.cognito_auth_role.arn
  publish = true
}

# Define the IAM role for the Lambda function

resource "aws_iam_role" "cognito_auth_role" { 
  name = "cognito-auth-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach an inline policy to the IAM role for Cognito authentication
resource "aws_iam_policy_attachment" "cognito_auth_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.cognito_auth_role.name]
}







