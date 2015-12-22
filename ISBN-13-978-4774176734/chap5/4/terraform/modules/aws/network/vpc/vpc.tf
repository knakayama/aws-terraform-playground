variable "name"       { default = "vpc" }
variable "cidrs"      { }
variable "account_id" { }

resource "aws_vpc" "vpc" {
  count                = 2
  cidr_block           = "${element(split(",", var.cidrs), count.index)}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags { Name = "${var.name}.${element(split(",", var.cidrs), count.index)}" }
}

resource "aws_vpc_peering_connection" "vpc" {
  peer_owner_id = "${var.account_id}"
  peer_vpc_id   = "${aws_vpc.vpc.0.id}"
  vpc_id        = "${aws_vpc.vpc.1.id}"
  auto_accept   = true
}

output "ids"                   { value = "${join(",", aws_vpc.vpc.*.id)}" }
output "peering_connection_id" { value = "${aws_vpc_peering_connection.vpc.id}" }
