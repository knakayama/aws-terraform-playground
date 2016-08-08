variable "name"            { default = "private" }
variable "vpc_id"          { }
variable "azs"             { }
variable "private_subnets" { }

resource "aws_subnet" "private" {
  count             = "${length(split(",", var.azs))}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.private_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"

  tags { Name = "${var.name}" }
}

output "subnet_ids" { value = "${join(",", aws_subnet.private.*.id)}" }
