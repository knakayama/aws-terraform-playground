resource "aws_vpc" "vpc_tokyo" {
  cidr_block           = "${var.vpc_cidrs["tokyo"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "public_tokyo" {
  vpc_id = "${aws_vpc.vpc_tokyo.id}"
}

resource "aws_subnet" "public_tokyo" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc_tokyo.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc_tokyo.cidr_block, 8, count.index + 1)}"
  availability_zone       = "${data.aws_availability_zones.az_tokyo.names[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_tokyo" {
  vpc_id = "${aws_vpc.vpc_tokyo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public_tokyo.id}"
  }

  route {
    cidr_block  = "${aws_subnet.public_oregon.0.cidr_block}"
    instance_id = "${aws_instance.vyos_tokyo.id}"
  }

  route {
    cidr_block  = "${aws_subnet.public_oregon.1.cidr_block}"
    instance_id = "${aws_instance.vyos_tokyo.id}"
  }
}

resource "aws_route_table_association" "public_tokyo" {
  count          = 2
  subnet_id      = "${element(aws_subnet.public_tokyo.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_tokyo.id}"
}

resource "aws_network_acl" "acl_tokyo" {
  vpc_id     = "${aws_vpc.vpc_tokyo.id}"
  subnet_ids = ["${aws_subnet.public_tokyo.*.id}"]

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
