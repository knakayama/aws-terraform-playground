variable "name" { default = "vpc" }
variable "cidr" { }

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags { Name = "${var.name}" }
}

output "id"         { value = "${aws_vpc.vpc.id}" }
output "cidr_block" { value = "${aws_vpc.vpc.cidr_block}" }
