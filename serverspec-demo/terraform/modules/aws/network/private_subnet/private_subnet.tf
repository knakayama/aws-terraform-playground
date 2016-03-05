variable "name"           { default = "public" }
variable "azs"            { }
variable "vpc_id"         { }
variable "subnet"         { }
variable "vpc_cidr"       { }
variable "nat_gateway_id" { }

resource "aws_subnet" "private" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.subnet}"
  availability_zone = "${element(split(",", var.azs), 1)}"

  tags { Name = "${var.name}" }
}

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_gateway_id}"
  }

  tags { Name = "${var.name}" }
}

output "subnet_id" { value = "${aws_subnet.private.id}" }
