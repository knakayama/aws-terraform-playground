variable "name"   { default = "private" }
variable "vpc_id" { }
variable "cidrs"  { }
variable "azs"    { }

resource "aws_subnet" "private" {
  count      = "${length(split(",", var.azs))}"
  vpc_id     = "${var.vpc_id}"
  cidr_block = "${element(split(",", var.cidrs), count.index)}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  map_public_ip_on_launch = false

  tags { Name = "${var.name}.${element(split(",", var.azs), count.index)}" }
}

output "subnet_ids" { value = "${join(",", aws_subnet.private.*.id)}" }
