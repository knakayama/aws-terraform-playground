resource "aws_vpc" "vpc_oregon" {
  provider             = "aws.oregon"
  cidr_block           = "${var.vpc_cidrs["oregon"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public_oregon" {
  provider = "aws.oregon"
  vpc_id   = "${aws_vpc.vpc_oregon.id}"
}

resource "aws_subnet" "public_oregon" {
  provider                = "aws.oregon"
  vpc_id                  = "${aws_vpc.vpc_oregon.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidrs["oregon"], 8, 1)}"
  availability_zone       = "${data.aws_availability_zones.az_oregon.names[0]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_oregon" {
  provider = "aws.oregon"
  vpc_id   = "${aws_vpc.vpc_oregon.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public_oregon.id}"
  }
}

resource "aws_route_table_association" "public_oregon" {
  provider       = "aws.oregon"
  subnet_id      = "${aws_subnet.public_oregon.id}"
  route_table_id = "${aws_route_table.public_oregon.id}"
}

resource "aws_network_acl" "acl_oregon" {
  provider   = "aws.oregon"
  vpc_id     = "${aws_vpc.vpc_oregon.id}"
  subnet_ids = ["${aws_subnet.public_oregon.id}"]

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
