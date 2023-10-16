resource "aws_vpc_endpoint" "s3" {
  count = terraform.workspace == "dev" ? 1 : 0
  vpc_id       =  var.vpc_id["${local.Env}"]
  service_name = "com.amazonaws.us-east-1.s3"

  tags = local.common_tags
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each = toset(var.s3_endpoint-route_table_ids[local.Env])
  route_table_id  = each.key
  vpc_endpoint_id = aws_vpc_endpoint.s3.0.id
}

