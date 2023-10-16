resource "aws_cognito_user_pool" "kinetix-user-pool" {
  
  name = "userpreview"
  
  schema {
    attribute_data_type = "String"
    developer_only_attribute = "false"
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

}

resource "aws_cognito_identity_provider" "okta" {
  user_pool_id  = aws_cognito_user_pool.tfer--kinetix-user-pool.id
  provider_name = "okta"
  provider_type = "OIDC"

  provider_details = {
    authorize_scopes          = "openid profile email"
    client_id                 = ""
    client_secret             = data.aws_secretsmanager_secret_version.current.secret_string
    attributes_request_method = "GET"
    oidc_issuer               = ""
  }

}

resource "aws_cognito_user_pool_client" "client" {
  name            = "app_client"
  generate_secret = true


  user_pool_id                  = aws_cognito_user_pool.kinetix-user-pool.id
  explicit_auth_flows           = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  prevent_user_existence_errors = "ENABLED"

  callback_urls                        = []
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "phone", "profile", "aws.cognito.signin.user.admin"]
  supported_identity_providers         = ["${aws_cognito_identity_provider.okta.provider_name}"]



}

resource "aws_cognito_user_pool_domain" "domain" {
  domain          = ""
  user_pool_id    = aws_cognito_user_pool.kinetix-user-pool.id
  certificate_arn = "arn:aws:acm:us-east-1:289366451648:certificate/f540be7a-1116-40ae-8f01-c6355037a8cb"
}

data "aws_route53_zone" "example" {
  name = "kinetix.financial"
}

resource "aws_route53_record" "auth-cognito-A" {
  name    = aws_cognito_user_pool_domain.domain.domain
  type    = "A"
  zone_id = data.aws_route53_zone.example.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cognito_user_pool_domain.domain.cloudfront_distribution_arn
    # This zone_id is fixed
    zone_id = "Z2FDTNDATAQYW2"
  }
}

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.example.zone_id
  name    = "kinetix.financial"
  type    = "A"
  ttl     = "300"
  records = ["127.0.0.1"]
}


 
