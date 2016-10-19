variable "region" {
  default = "ap-northeast-1"
}

variable "env" {
  default = [
    "dev",
    "prd",
  ]
}

variable "vpc_cidrs" {
  default = {
    dev_1 = "172.16.0.0/16"
    dev_2 = "172.17.0.0/16"
    prd_1 = "172.18.0.0/16"
    prd_2 = "172.19.0.0/16"
  }
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  count                = "${length(var.vpc_cidrs)}"
  cidr_block           = "${var.vpc_cidrs["${var.env[count.index / 2]}_${count.index % 2 + 1}"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
