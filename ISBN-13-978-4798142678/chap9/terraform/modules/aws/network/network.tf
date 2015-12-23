variable "name"            { }
variable "vpc_cidr"        { }
variable "azs"             { }
variable "public_subnet"   { }
variable "private_subnets" { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  vpc_id = "${module.vpc.id}"
  cidr   = "${var.public_subnet}"
  azs    = "${var.azs}"
}

module "private_subnet" {
  source = "./private_subnet"

  name   = "${var.name}-private"
  vpc_id = "${module.vpc.id}"
  cidrs  = "${var.private_subnets}"
  azs    = "${var.azs}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.id}"
  subnet_ids = ["${module.public_subnet.subnet_id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# VPC
output "vpc_id" { value = "${module.vpc.id}" }

# Subnets
output "public_subnet_id"   { value = "${module.public_subnet.subnet_id}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }
