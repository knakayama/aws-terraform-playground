variable "name" {
  default = "tf-vpc-vpn-demo"
}

variable "regions" {
  default = {
    "oregon" = "us-west-2"
    "tokyo"  = "ap-northeast-1"
  }
}

variable "vpc_cidrs" {
  default = {
    "oregon" = "172.16.0.0/16"
    "tokyo"  = "10.0.0.0/16"
  }
}

variable "ec2_instance_type" {
  default = "t2.nano"
}

variable "vyos_instance_type" {
  default = "t2.micro"
}

data "aws_availability_zones" "az_tokyo" {}

data "aws_availability_zones" "az_oregon" {
  provider = "aws.oregon"
}

data "aws_ami" "amazon_linux_oregon" {
  provider    = "aws.oregon"
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

data "aws_ami" "vyos_tokyo" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "description"
    values = ["*VyOS*"]
  }
}

data "aws_ami" "amazon_linux_tokyo" {
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
