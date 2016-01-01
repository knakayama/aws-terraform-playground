variable "name"   { default = "public" }
variable "vpc_id" { }
variable "subnet" { }

resource "aws_internet_gateway" "public" {
  vpc_id = "${var.vpc_id}"

  tags { Name = "${var.name}" }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnet}"
  map_public_ip_on_launch = true

  tags { Name = "${var.name}" }
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

output "subnet_id" { value = "${aws_subnet.public.id}" }
