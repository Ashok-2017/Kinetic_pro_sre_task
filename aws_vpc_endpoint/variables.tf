locals {
  Env = terraform.workspace == "default" ? "prod" : terraform.workspace
  Environment = terraform.workspace == "default" ? "production" : terraform.workspace == "stg" ? "staging" : "development"
  RegionCode = "ue1"
  common_tags = {
    environment = local.Environment
  }
}

variable "vpc_id" {
  type = map(string)
  default = {
    "stg"  = ""
    "dev"  = ""
    "prod" = ""
  }
}

variable "subnet_ids" {
  type = map(list(string))
  default = {
    "stg" = [
      "",
      ""
    ],
    "dev" = [
      "",
      ""
    ],
    "prod" = [
      "",
      ""
    ]
  }
}

variable "security_group_ids" {
  type = map(map(list(string)))
  default ={
    "stg" = {
      "kinetix-api" = [
        ""
      ]
    }
    "dev" = {
      "kinetix-api" = [
        ""
       ]
      "kinetix-api" = [
        ""
      ]
    }
  }
}

data "aws_security_group" "sl_fep_sg" {
  name = "api-endpoint-sl-${local.Env}-fep-sg"
}

