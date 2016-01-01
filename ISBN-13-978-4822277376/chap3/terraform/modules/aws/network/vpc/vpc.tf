variable "name" { default = "vpc" }
variable "cidr" { }

resource "aws_vpc" "vpc" {
  cidr_block         = "${var.cidr}"
  enable_dns_support = true

  tags { Name = "${var.name}" }
}

output "id" { value = "${aws_vpc.vpc.id}" }
