variable "name"           { }
variable "vpc_cidr"       { }
variable "azs"            { }
variable "region"         { }
variable "private_subnet" { }
variable "public_subnet"  { }

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

  name           = "${var.name}-private"
  vpc_id         = "${module.vpc.id}"
  cidr           = "${var.private_subnet}"
  azs            = "${var.azs}"
  nat_gateway_id = "${module.public_subnet.nat_gateway_id}"
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

  tags { Name = "${var.name}-all" }
}

output "vpc_id"            { value = "${module.vpc.id}" }
output "public_subnet_id"  { value = "${module.public_subnet.subnet_id}" }
output "private_subnet_id" { value = "${module.private_subnet.subnet_id}" }
