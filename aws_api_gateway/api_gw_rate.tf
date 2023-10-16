resource "aws_api_gateway_usage_plan" "kinetix" {
  name = "kinetix-usage-plan"
  description = " implement rate limit"
  product_code = "kinetix"

  # Define throttling and quota settings
  
  throttle {
    rate_limit = 100 # Requests per second
    burst_limit = 200 # Maximum allowed burst
  }
  
  quota_settings {
    limit = 10000 # Total requests allowed
    offset = 2 #Optional, starting quota amount
    period = "MONTH" # Quota reset period (DAY, WEEK, or MONTH)
  }

  # Associate the API Gateway API with the usage plan
  api_stages {
    api_id     = aws_api_gateway_rest_api.kinetix.id
    stage      = aws_api_gateway_deployment.kinetix.stage_name
    throttle {
      rate_limit      = 100
      burst_limit     = 200
    }
  }
} 
