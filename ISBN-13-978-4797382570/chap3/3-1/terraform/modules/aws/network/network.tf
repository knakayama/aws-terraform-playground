variable name             { }
variable vpc_cidr         { }
variable azs              { }
variable public_subnets   { }
variable private_subnets  { }
variable web_instance_ids { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name           = "${var.name}-public"
  vpc_id         = "${module.vpc.id}"
  azs            = "${var.azs}"
  public_subnets = "${var.public_subnets}"
}

module "private_subnet" {
  source = "./private_subnet"

  name            = "${var.name}-private"
  vpc_id          = "${module.vpc.id}"
  azs             = "${var.azs}"
  private_subnets = "${var.private_subnets}"
}

module "elb" {
  source = "./elb"

  name              = "${var.name}-elb"
  vpc_id            = "${module.vpc.id}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  web_instance_ids  = "${var.web_instance_ids}"
}

resource "aws_network_acl" "acl" {
  vpc_id   = "${module.vpc.id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids), split(",", module.private_subnet.subnet_ids))}"]

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

# VPC
output "vpc_id" { value = "${module.vpc.id}" }

# Load Balancer
output "elb_dns_name" { value = "${module.elb.dns_name}" }
output "elb_sg_id"    { value = "${module.elb.sg_id}" }

# Subnets
output "public_subnet_ids"  { value = "${module.public_subnet.subnet_ids}" }
output "private_subnet_ids" { value = "${module.private_subnet.subnet_ids}" }
