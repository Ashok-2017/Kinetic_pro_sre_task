resource "aws_api_gateway_rest_api" "main" {
  name = "apigw-${local.Env}-rest-api-${local.RegionCode}-all"

  endpoint_configuration {
    types = ["PRIVATE"]
    vpc_endpoint_ids = var.VpceIds[local.Env]
  }
  tags = {
    "environment": local.Environment
  }
}

resource "aws_api_gateway_rest_api_policy" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  policy = templatefile(
    "${path.module}/policies/resource_policy.json.tmpl",
    {
      VpceIds = local.VpceIdsJson,
      ApiId=aws_api_gateway_rest_api.main.id,
      CardsTrustedRoles = var.CardsTrustedRoles[local.Env]
      SidekiRoles = var.SidekiRoles[local.Env]
    }
  )
}

resource "aws_api_gateway_method_settings" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.live.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_deployment" "live" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  lifecycle {
    create_before_destroy = true
  }
  triggers = {
    redeployment = join("", [
      for file in fileset(path.module, "**.tf"):
      filesha1(file)
    ])
  }

  variables = {
    deployed_at = timestamp()
  }
}

resource "aws_api_gateway_stage" "live" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.live.id
  stage_name    = "live"
  cache_cluster_enabled = false


