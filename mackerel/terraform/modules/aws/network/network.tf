variable "name"          { }
variable "vpc_cidr"      { }
variable "az"            { }
variable "public_subnet" { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name          = "${var.name}-public"
  vpc_id        = "${module.vpc.id}"
  az            = "${var.az}"
  public_subnet = "${var.public_subnet}"
}

resource "aws_network_acl" "acl" {
  vpc_id = "${module.vpc.id}"
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
