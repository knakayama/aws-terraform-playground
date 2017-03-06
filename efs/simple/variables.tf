variable "env" {
  default = "efs-simple"
}

variable "region" {
  default = "us-west-2"
}

variable "subnet_id" {}

data "aws_subnet" "selected" {
  id = "${var.subnet_id}"
}

variable "vpc_id" {}

data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}
