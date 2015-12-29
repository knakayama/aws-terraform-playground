variable "name"          { }
variable "vpc_cidr"      { }
variable "public_subnet" { }
variable "az"            { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name     = "${var.name}-public"
  az       = "${var.az}"
  vpc_id   = "${module.vpc.id}"
  cidr     = "${var.public_subnet}"
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

output "vpc_id"           { value = "${module.vpc.id}" }
output "public_subnet_id" { value = "${module.public_subnet.subnet_id}" }
