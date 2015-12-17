variable "name"           {}
variable "vpc_cidr"       {}
variable "azs"            {}
variable "region"         {}
variable "public_subnets" {}

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.public_subnets}"
  azs    = "${var.azs}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.public_subnet.subnet_ids}"]

  ingress {
    protocol   = "-1"
    rule_to    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_to    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# VPC
output "vpc_id" { value = "${module.vpc.vpc_id}" }

# Subnets
output "public_subnet_ids" { value = "${module.public_subnet.subnet_ids}" }
