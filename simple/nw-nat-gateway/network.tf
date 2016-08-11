resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}-vpc"
  }
}

resource "aws_internet_gateway" "frontend_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}-igw"
  }
}

resource "aws_subnet" "frontend_subnet" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index+1)}"
  availability_zone       = "${azs[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "frontend-subnet-${count.index}"
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.frontend_subnet.0.id}"
  depends_on    = ["aws_internet_gateway.frontend_subnet"]
}

resource "aws_route_table" "frontend_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.frontend_subnet.id}"
  }

  tags {
    Name = "frontend-subnet-rtb"
  }
}

resource "aws_route_table_association" "frontend_subnet" {
  count          = 2
  subnet_id      = "${element(aws_subnet.frontend_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.frontend_subnet.id}"
}

resource "aws_subnet" "application_subnet" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index+101)}"
  availability_zone       = "${azs[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "application-subnet-${count.index}"
  }
}

resource "aws_route_table" "application_subnet" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }

  tags {
    Name = "application-subnet-rtb"
  }
}

resource "aws_route_table_association" "application_subnet" {
  count          = 2
  subnet_id      = "${element(aws_subnet.application_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.application_subnet.id}"
}

resource "aws_subnet" "datastore_subnet" {
  count                   = 2
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(var.vpc_cidr, 8, count.index+201)}"
  availability_zone       = "${azs[count.index]}"
  map_public_ip_on_launch = false

  tags {
    Name = "datastore-subnet-${count.index}"
  }
}

resource "aws_vpc_endpoint" "vpc_endpoint" {
  vpc_id          = "${aws_vpc.vpc.id}"
  service_name    = "com.amazonaws.${var.region}.s3"
  policy          = "${file("${path.module}/policies/vpc_endpoint_policy.json")}"
  route_table_ids = ["${aws_route_table.frontend_subnet.id}", "${aws_route_table.application_subnet.id}"]
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.frontend_subnet.*.id}", "${aws_subnet.application_subnet.*.id}"]

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

  tags {
    Name = "${var.name}-acl"
  }
}
