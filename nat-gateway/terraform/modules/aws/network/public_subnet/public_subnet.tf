variable "name"   { default = "public" }
variable "vpc_id" { }
variable "cidr"   { }
variable "azs"    { }

resource "aws_internet_gateway" "public" {
  vpc_id = "${var.vpc_id}"

  tags { Name = "${var.name}" }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.cidr}"
  availability_zone       = "${element(split(",", var.azs), 0)}"
  map_public_ip_on_launch = true

  tags { Name = "${var.name}" }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public.id}"
  depends_on    = ["aws_internet_gateway.public"]
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags { Name = "${var.name}" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

output "subnet_id"      { value = "${aws_subnet.public.id}" }
output "nat_gateway_id" { value = "${aws_nat_gateway.nat.id}" }
