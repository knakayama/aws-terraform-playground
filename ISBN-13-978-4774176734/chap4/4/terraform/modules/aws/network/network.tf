variable "name"           { }
variable "vpc_cidr"       { }
variable "public_subnets" { }
variable "azs"            { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  azs    = "${var.azs}"
  vpc_id = "${module.vpc.id}"
  cidrs  = "${var.public_subnets}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.id}"
  subnet_ids = ["${split(",", module.public_subnet.subnet_ids)}"]

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
output "public_subnet_ids" { value = "${module.public_subnet.subnet_ids}" }
