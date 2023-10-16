resource "aws_vpc_endpoint" "kinetix_api" {
    vpc_id              = var.vpc_id["${local.Env}"]
    service_name        = "com.amazonaws.us-east-1.execute-api"
    subnet_ids          = var.subnet_ids["${local.Env}"]
    security_group_ids  = concat(var.security_group_ids["${local.Env}"]["kinetix-api"], [data.aws_security_group.sl_fep_sg.id])
    private_dns_enabled = true
    vpc_endpoint_type   = "Interface"
    tags = local.common_tags

}

data "aws_network_interface" "kinetix_api" {
    for_each = toset(aws_vpc_endpoint.kinetix_api.network_interface_ids)
    id = each.value
}

module "kinetix_api_target_group" {
    source                      = "../../modules/target_group"
    name                        = "ec2-alb-${local.RegionCode}-${local.Env}-kinetix-api"
    port                        = 443
    protocol                    = "HTTPS"
    vpc_id                      = var.vpc_id["${local.Env}"]
    target_type                 = "ip"
    env                         = "prod"
    targets                     = [for eni in data.aws_network_interface.kinetix_api : eni.private_ip ]
    ping_path                   = "/ping"
    matcher                     = "200,403"
}

module "kinetix_api_alb" {
    source                      = "../../modules/aws_lb"
    name                        = "alb-${local.RegionCode}-${local.Env}-kinetix-api"
    internal                    = true
    security_groups             = concat(var.security_group_ids["${local.Env}"]["kinetix-api"], [data.aws_security_group.sl_fep_sg.id])
    subnet_ids                  = var.subnet_ids["${local.Env}"]
    idle_timeout                = 300
    access_logs_bucket          = "s3-${local.Env}-access-logs-${local.RegionCode}-all"
    access_logs_prefix          = "alb-${local.RegionCode}-${local.Env}-kinetix-api"
    certificate_arn             = data.aws_acm_certificate.arn
    target_group_arn            = module.kinetix_api_target_group.lb_arn
    env                         = local.Environment
}

