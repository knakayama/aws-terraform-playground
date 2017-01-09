variable "name" {
  default = "prj"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

data "aws_availability_zones" "az" {}
