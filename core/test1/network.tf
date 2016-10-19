resource "aws_vpc" "vpc" {
  count                = 2
  cidr_block           = "${var.vpc_cidrs["${var.env[0+count.index]}"]}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}
