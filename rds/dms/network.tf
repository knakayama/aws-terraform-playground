resource "aws_vpc" "vpc" {
  count                = "${var.cnt}"
  cidr_block           = "${var.vpc_cidr}.${17-count.index}.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_vpc_peering_connection" "vpc" {
  peer_owner_id = "${var.account_id}"
  vpc_id        = "${aws_vpc.vpc.0.id}"
  peer_vpc_id   = "${aws_vpc.vpc.1.id}"
  auto_accept   = true
}

resource "aws_internet_gateway" "public" {
  count  = "${var.cnt}"
  vpc_id = "${element(aws_vpc.vpc.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  count                   = "${var.cnt}"
  vpc_id                  = "${element(aws_vpc.vpc.*.id, count.index)}"
  cidr_block              = "${cidrsubnet(element(aws_vpc.vpc.*.cidr_block, count.index), 8, 0)}"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  count  = "${var.cnt}"
  vpc_id = "${element(aws_vpc.vpc.*.id, count.index)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.public.*.id, count.index)}"
  }

  route {
    cidr_block                = "172.${count.index+16}.0.0/16"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${var.cnt}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_subnet" "private1" {
  count             = "${var.cnt}"
  vpc_id            = "${aws_vpc.vpc.0.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.0.cidr_block, 8, count.index+100)}"
  availability_zone = "${var.azs[count.index]}"
}

resource "aws_subnet" "private2" {
  count             = "${var.cnt}"
  vpc_id            = "${aws_vpc.vpc.1.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.1.cidr_block, 8, count.index+100)}"
  availability_zone = "${var.azs[count.index]}"
}

resource "aws_network_acl" "acl" {
  count      = "${var.cnt}"
  vpc_id     = "${element(aws_vpc.vpc.*.id, count.index)}"
  subnet_ids = ["${element(aws_subnet.public.*.id, count.index)}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
