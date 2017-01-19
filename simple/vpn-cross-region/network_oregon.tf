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
  count                   = 2
  provider                = "aws.oregon"
  vpc_id                  = "${aws_vpc.vpc_oregon.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc_oregon.cidr_block, 8, count.index + 1)}"
  availability_zone       = "${data.aws_availability_zones.az_oregon.names[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public_oregon" {
  provider         = "aws.oregon"
  vpc_id           = "${aws_vpc.vpc_oregon.id}"
  propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public_oregon.id}"
  }
}

resource "aws_route_table_association" "public_oregon" {
  count          = 2
  provider       = "aws.oregon"
  subnet_id      = "${element(aws_subnet.public_oregon.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_oregon.id}"
}

resource "aws_vpn_gateway" "vgw" {
  provider = "aws.oregon"
  vpc_id   = "${aws_vpc.vpc_oregon.id}"
}

resource "aws_customer_gateway" "cgw" {
  provider   = "aws.oregon"
  bgp_asn    = 65000
  ip_address = "${aws_instance.vyos_tokyo.public_ip}"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  provider            = "aws.oregon"
  vpn_gateway_id      = "${aws_vpn_gateway.vgw.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = false

  tags {
    Name = "${var.name}"
  }
}

resource "aws_network_acl" "acl_oregon" {
  provider   = "aws.oregon"
  vpc_id     = "${aws_vpc.vpc_oregon.id}"
  subnet_ids = ["${aws_subnet.public_oregon.*.id}"]

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
