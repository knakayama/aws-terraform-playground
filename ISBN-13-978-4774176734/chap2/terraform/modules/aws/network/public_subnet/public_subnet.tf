variable "name"   { default = "public" }
variable "vpc_id" { }
variable "cidrs"  { }
variable "azs"    { }

resource "aws_internet_gateway" "public" {
  vpc_id = "${var.vpc_id}"

  tags { Name = "${var.name}" }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(split(",", var.cidrs), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  count                   = "${length(split(",", var.cidrs))}"
  map_public_ip_on_launch = false

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}"
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

output "subnet_ids" { value = "${join(",", aws_subnet.public.*.id)}" }
