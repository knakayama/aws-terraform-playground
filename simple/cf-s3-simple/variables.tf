variable "name" {
  default = "cf-s3-simple"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "cf_config" {
  default = {
    price_class = "PriceClass_200"
  }
}

data "aws_availability_zones" "az" {}

variable "acm_config" {
  default = {
    domain = ""
  }
}

data "aws_acm_certificate" "acm" {
  provider = "aws.virginia"
  domain   = "*.${var.acm_config["domain"]}"
}
