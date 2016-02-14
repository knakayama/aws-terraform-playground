variable "name"                      { default = "public" }
variable "azs"                       { }
variable "vpc_ids"                   { }
variable "subnets"                   { }
variable "vpc_cidrs"                 { }
variable "vpc_peering_connection_id" { }

# https://github.com/hashicorp/terraform/issues/444
variable "vpc_cidrs_table" {
  default = {
    "0" = "172.17.0.0/16"
    "1" = "172.16.0.0/16"
  }
}

resource "aws_internet_gateway" "public" {
  count  = "${length(split(",", var.azs))}"
  vpc_id = "${element(split(",", var.vpc_ids), count.index)}"

  tags { Name = "${var.name}.${element(split(",", var.vpc_ids), count.index)}" }
}

resource "aws_subnet" "public" {
  count                   = "${length(split(",", var.azs))}"
  vpc_id                  = "${element(split(",", var.vpc_ids), count.index)}"
  cidr_block              = "${element(split(",", var.subnets), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  map_public_ip_on_launch = true

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
}

resource "aws_route_table" "public" {
  count  = "${length(split(",", var.azs))}"
  vpc_id = "${element(split(",", var.vpc_ids), count.index)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.public.*.id, count.index)}"
  }

  route {
    cidr_block                = "${lookup(var.vpc_cidrs_table, count.index)}"
    vpc_peering_connection_id = "${var.vpc_peering_connection_id}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.azs))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
