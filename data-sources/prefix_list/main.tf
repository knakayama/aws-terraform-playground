provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
}

resource "aws_vpc_endpoint" "private_s3" {
  vpc_id       = "${aws_vpc.vpc.id}"
  service_name = "com.amazonaws.ap-northeast-1.s3"
}

data "aws_prefix_list" "private_s3" {
  prefix_list_id = "${aws_vpc_endpoint.private_s3.prefix_list_id}"
}

output "prefix_list_id" {
  value = "${data.aws_prefix_list.private_s3.id}"
}

output "prefix_list_name" {
  value = "${data.aws_prefix_list.private_s3.name}"
}

output "prefix_list_cidr_blocks" {
  value = "${data.aws_prefix_list.private_s3.cidr_blocks}"
}
