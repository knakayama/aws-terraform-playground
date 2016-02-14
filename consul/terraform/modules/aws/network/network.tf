variable "name"           { }
variable "vpc_cidrs"      { }
variable "account_id"     { }
variable "public_subnets" { }
variable "azs"            { }

module "vpc" {
  source = "./vpc"

  name       = "${var.name}-vpc"
  cidrs      = "${var.vpc_cidrs}"
  account_id = "${var.account_id}"
}

module "public_subnet" {
  source = "./public_subnet"

  name                      = "${var.name}-public"
  azs                       = "${var.azs}"
  vpc_ids                   = "${module.vpc.ids}"
  subnets                   = "${var.public_subnets}"
  vpc_cidrs                 = "${var.vpc_cidrs}"
  vpc_peering_connection_id = "${module.vpc.peering_connection_id}"
}

resource "aws_network_acl" "acl" {
  count      = "${length(split(",", var.azs))}"
  vpc_id     = "${element(split(",", module.vpc.ids), count.index)}"
  subnet_ids = ["${element(split(",", module.public_subnet.subnet_ids), count.index)}"]

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

output "vpc_ids"           { value = "${module.vpc.ids}" }
output "public_subnet_ids" { value = "${module.public_subnet.subnet_ids}" }
