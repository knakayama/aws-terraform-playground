variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

data "aws_availability_zones" "az" {}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index+1)}"
  availability_zone       = "${data.aws_availability_zones.az.names[count.index]}"
  map_public_ip_on_launch = true
}

output "az_names" {
  value = "${data.aws_availability_zones.az.names}"
}
