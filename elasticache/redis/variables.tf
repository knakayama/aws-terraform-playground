variable "name" {
  default = "rds-simple"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "instance_type" {
  default = "t2.nano"
}

variable "redis_config" {
  default = {
    engine                = "redis"
    engine_version        = "2.8.24"
    node_type             = "cache.t2.micro"
    replication_node_type = "cache.m3.medium"
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
