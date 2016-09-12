variable "name" {
  default = "multi-behavior"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "email_address" {
  default = "_YOUR_EMAIL_"
}

variable "instance_types" {
  default = {
    bastion = "t2.nano"
    app     = "t2.nano"
  }
}

variable "asg_config" {
  default = {
    min     = 1
    max     = 1
    desired = 1
  }
}

variable "db_config" {
  default = {
    instance_class = "db.r3.large"
    family         = "aurora5.6"
    db_name        = "aurora"
    username       = "aurora"
    password       = "pAssw0rd"
  }
}

variable "domain_config" {
  default = {
    domain             = "_YOUR_DOMAIN_"
    cf_sub_domain      = "cf"
    elb_sub_domain     = "elb"
    s3_sub_domain      = "img"
    bastion_sub_domain = "bastion"
  }
}

variable "cf_config" {
  default = {
    price_class = "PriceClass_200"
  }
}

variable "elasticache_config" {
  default = {
    cluster_id            = "redis-cluster"
    engine                = "redis"
    engine_version        = "2.8.24"
    node_type             = "cache.t2.micro"
    replication_node_type = "cache.m3.medium"
    maintenance_window    = "sun:05:00-sun:06:00"
    family                = "redis2.8"
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
