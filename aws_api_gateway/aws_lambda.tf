resource "aws_lambda_function" "hello0" {
  filename = "hello0.zip"
  function_name = "hello0-lambda"
  role = aws_iam_role.lambda_exec_role.arn
  handler = "index.handler"
  runtime = "python3.8"
  environment {
    variables = {
      RESPONSE = "hello0"
    }
   }
  }
  
resource "aws_lambda_function" "hello1" {
  filename      = "hello1.zip" # Path to your Lambda deployment package
  function_name = "hello1-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "python3.8" # Choose the appropriate runtime
  environment {
    variables = {
      RESPONSE = "hello1"
    }
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role"
  
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy_attachment" "lambda_execution" {
  name = "lambda-execution-policy"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_exec_role.name]
}
