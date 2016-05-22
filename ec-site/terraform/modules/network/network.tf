variable "name" {}

variable "vpc_cidr" {}

variable "azs" {}

variable "public_subnets" {}

variable "private_subnets_web" {}

variable "private_subnets_db" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(split(",", var.public_subnets))}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.name}-public-${count.index+1}"
  }
}

resource "aws_eip" "public" {
  count = "${length(split(",", var.public_subnets))}"
  vpc   = true
}

resource "aws_nat_gateway" "public" {
  count         = "${length(split(",", var.public_subnets))}"
  allocation_id = "${element(aws_eip.public.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.azs))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_subnet" "private_web" {
  count             = "${length(split(",", var.azs))}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.private_subnets_web), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"

  tags {
    Name = "${var.name}-private-web-${count.index+1}"
  }
}

resource "aws_route_table" "private_web" {
  count  = "${length(split(",", var.azs))}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.public.*.id, count.index)}"
  }
}

resource "aws_route_table_association" "private_web" {
  count          = "${length(split(",", var.azs))}"
  subnet_id      = "${element(aws_subnet.private_web.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_web.*.id, count.index)}"
}

resource "aws_subnet" "private_db" {
  count             = "${length(split(",", var.azs))}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${element(split(",", var.private_subnets_db), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"

  tags {
    Name = "${var.name}-private-db-${count.index+1}"
  }
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

  tags {
    Name = "${var.name}-all"
  }
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "private_subnet_ids_web" {
  value = "${join(",", aws_subnet.private_web.*.id)}"
}

output "private_subnet_ids_db" {
  value = "${join(",", aws_subnet.private_db.*.id)}"
}
