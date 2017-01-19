resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = "${var.vgw_config["ip_address"]}"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  vpn_gateway_id      = "${aws_vpn_gateway.vgw.id}"
  customer_gateway_id = "${aws_customer_gateway.cgw.id}"
  type                = "ipsec.1"
  static_routes_only  = false

  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index)}"
  availability_zone       = "${data.aws_availability_zones.az.names[count.index]}"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${aws_vpn_gateway.vgw.id}"]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

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
