variable "name" {
  default = "elb-simple"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "spot_config" {
  default = {
    instance_type        = "c3.large"
    price                = "0.15"
    wait_for_fulfillment = true
    type                 = "one-time"
  }
}

variable "acm_config" {
  default = {
    domain = ""
  }
}

data "aws_acm_certificate" "acm" {
  domain   = "${var.acm_config["domain"]}"
  statuses = ["ISSUED"]
}

data "aws_availability_zones" "az" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}
