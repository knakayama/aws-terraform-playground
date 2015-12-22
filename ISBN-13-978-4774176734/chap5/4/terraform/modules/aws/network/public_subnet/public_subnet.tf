variable "name"                      { default = "public" }
variable "azs"                       { }
variable "vpc_ids"                   { }
variable "subnets"                   { }
variable "vpc_cidrs"                 { }
variable "vpc_peering_connection_id" { }

resource "aws_internet_gateway" "public" {
  count  = 2
  vpc_id = "${element(split(",", var.vpc_ids), count.index)}"

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = "${element(split(",", var.vpc_ids), count.index)}"
  cidr_block              = "${element(split(",", var.subnets), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  map_public_ip_on_launch = true

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
}

resource "aws_route_table" "public1" {
  vpc_id = "${element(split(",", var.vpc_ids), 0)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.public.*.id, 0)}"
  }

  route {
    cidr_block                = "${element(split(",", var.vpc_cidrs), 1)}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
  }

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), 0)}" }
}

resource "aws_route_table" "public2" {
  vpc_id = "${element(split(",", var.vpc_ids), 1)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.public.*.id, 1)}"
  }

  route {
    cidr_block                = "${element(split(",", var.vpc_cidrs), 0)}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
  }

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), 1)}" }
}

resource "aws_route_table_association" "public1" {
  subnet_id      = "${aws_subnet.public.0.id}"
  route_table_id = "${aws_route_table.public1.id}"
}

resource "aws_route_table_association" "public2" {
  subnet_id      = "${aws_subnet.public.1.id}"
  route_table_id = "${aws_route_table.public2.id}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
