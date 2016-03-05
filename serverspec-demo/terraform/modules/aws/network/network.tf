variable "name"           { }
variable "vpc_cidr"       { }
variable "public_subnet"  { }
variable "private_subnet" { }
variable "azs"            { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name     = "${var.name}-public"
  azs      = "${var.azs}"
  vpc_id   = "${module.vpc.id}"
  subnet   = "${var.public_subnet}"
  vpc_cidr = "${var.vpc_cidr}"
}

module "private_subnet" {
  source = "./private_subnet"

  name           = "${var.name}-private"
  azs            = "${var.azs}"
  vpc_id         = "${module.vpc.id}"
  subnet         = "${var.private_subnet}"
  vpc_cidr       = "${var.vpc_cidr}"
  nat_gateway_id = "${module.public_subnet.nat_gateway_id}"
}

resource "aws_network_acl" "acl" {
  count      = 2
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
