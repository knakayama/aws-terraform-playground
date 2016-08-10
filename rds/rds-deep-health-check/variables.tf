variable "name" {
  default = "rds-deep-health-check"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "asg_config" {
  default = {
    instance_type = "t2.nano"
    desired       = 1
    min           = 1
    max           = 1
  }
}

variable "db_config" {
  default = {
    engine         = "mysql"
    engine_version = "5.7.11"
    instance_class = "db.t2.micro"
    username       = "master_username"
    password       = "master_password"
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
