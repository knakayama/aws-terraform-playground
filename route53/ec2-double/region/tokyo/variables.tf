variable "name" {
  default = "double-tokyo"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "web_instance_type" {
  default = "t2.micro"
}

variable "domain_config" {
  default = {
    domain = "_YOUR_DOMAIN_"
  }
}

variable "cf_config" {
  default = {
    price_class = "PriceClass_200"
    acm_arn     = "_YOUR_ACM_ARN_"
  }
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
