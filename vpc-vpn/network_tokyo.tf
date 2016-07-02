resource "aws_vpc" "vpc_tokyo" {
  cidr_block           = "${var.vpc_cidrs["tokyo"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public_tokyo" {
  vpc_id = "${aws_vpc.vpc_tokyo.id}"
}

resource "aws_subnet" "public_tokyo" {
  vpc_id                  = "${aws_vpc.vpc_tokyo.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidrs["tokyo"], 8, 1)}"
  availability_zone       = "${data.aws_availability_zones.az_tokyo.names[0]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_tokyo" {
  vpc_id = "${aws_vpc.vpc_tokyo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public_tokyo.id}"
  }
}

resource "aws_route_table_association" "public_tokyo" {
  subnet_id      = "${aws_subnet.public_tokyo.id}"
  route_table_id = "${aws_route_table.public_tokyo.id}"
}

resource "aws_network_acl" "acl_tokyo" {
  vpc_id     = "${aws_vpc.vpc_tokyo.id}"
  subnet_ids = ["${aws_subnet.public_tokyo.id}"]

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
