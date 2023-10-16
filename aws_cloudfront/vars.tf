variable "origin_name" {}
variable "certificate_arn" {}

variable "destination_url" {
  default = "www.kinetixpro.com"
}

variable "forward_query_string" {
  default = false
}

variable "forward_cookies" {
  default = "none"
}

