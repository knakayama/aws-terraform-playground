variable name             { }
variable vpc_cidr         { }
variable azs              { }
variable public_subnets   { }
variable web_instance_ids { }

module "vpc" {
  source = "./vpc"

  name = "${var.name}-vpc"
  cidr = "${var.vpc_cidr}"
}

module "public_subnet" {
  source = "./public_subnet"

  name   = "${var.name}-public"
  azs    = "${var.azs}"
  vpc_id = "${module.vpc.vpc_id}"
  cidrs  = "${var.public_subnets}"
}

module "load_balancer" {
  source = "./load_balancer"

  name              = "${var.name}-load-balancer"
  vpc_id            = "${module.vpc.vpc_id}"
  public_subnet_ids = "${module.public_subnet.subnet_ids}"
  web_instance_ids  = "${var.web_instance_ids}"
}

resource "aws_network_acl" "acl" {
  vpc_id     = "${module.vpc.vpc_id}"
  subnet_ids = ["${concat(split(",", module.public_subnet.subnet_ids))}"]

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
output "vpc_id" { value = "${module.vpc.vpc_id}" }

# Subnets
output "public_subnet_ids" { value = "${module.public_subnet.subnet_ids}" }

# ELB
output "elb_dns_name" { value = "${module.load_balancer.dns_name}" }
