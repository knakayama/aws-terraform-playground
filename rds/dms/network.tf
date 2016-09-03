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

resource "aws_subnet" "public1" {
  count                   = "${var.cnt}"
  vpc_id                  = "${aws_vpc.vpc.0.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.0.cidr_block, 8, count.index)}"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  count                   = "${var.cnt}"
  vpc_id                  = "${aws_vpc.vpc.1.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.1.cidr_block, 8, count.index)}"
  availability_zone       = "${var.azs[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public1" {
  count  = "${var.cnt}"
  vpc_id = "${aws_vpc.vpc.0.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.0.id}"
  }

  route {
    cidr_block                = "${aws_vpc.vpc.1.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc.id}"
  }
}

resource "aws_route_table" "public2" {
  count  = "${var.cnt}"
  vpc_id = "${aws_vpc.vpc.1.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.1.id}"
  }

  route {
    cidr_block                = "${aws_vpc.vpc.0.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc.id}"
  }
}

resource "aws_route_table_association" "public1" {
  count          = "${var.cnt}"
  subnet_id      = "${element(aws_subnet.public1.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public1.*.id, count.index)}"
}

resource "aws_route_table_association" "public2" {
  count          = "${var.cnt}"
  subnet_id      = "${element(aws_subnet.public2.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public2.*.id, count.index)}"
}

resource "aws_subnet" "private" {
  count             = "${var.cnt}"
  vpc_id            = "${aws_vpc.vpc.1.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.1.cidr_block, 8, count.index+100)}"
  availability_zone = "${var.azs[count.index]}"
}

resource "aws_route_table" "private" {
  count  = "${var.cnt}"
  vpc_id = "${aws_vpc.vpc.1.id}"

  route {
    cidr_block                = "${aws_vpc.vpc.0.cidr_block}"
    vpc_peering_connection_id = "${aws_vpc_peering_connection.vpc.id}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${var.cnt}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_network_acl" "acl1" {
  vpc_id     = "${aws_vpc.vpc.0.id}"
  subnet_ids = ["${aws_subnet.public1.*.id}"]

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

resource "aws_network_acl" "acl2" {
  vpc_id     = "${aws_vpc.vpc.1.id}"
  subnet_ids = ["${aws_subnet.public2.*.id}"]

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
