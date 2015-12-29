variable "name"   { }
variable "region" { }

variable "vpc_cidr"       { }
variable "azs"            { }
variable "public_subnets" { }

variable "domain"     { }
variable "sub_domain" { }

variable "rds_username"      { }
variable "rds_password"      { }
variable "rds_engine"        { }
variable "rds_engine_ver"    { }
variable "rds_instance_type" { }
variable "rds_family"        { }

provider "aws" {
  region = "${var.region}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  vpc_cidr       = "${var.vpc_cidr}"
  azs            = "${var.azs}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name              = "${var.name}"
  vpc_id            = "${module.network.vpc_id}"
  public_subnet_ids = "${module.network.public_subnet_ids}"
  rds_username      = "${var.rds_username}"
  rds_password      = "${var.rds_password}"
  rds_engine        = "${var.rds_engine}"
  rds_engine_ver    = "${var.rds_engine_ver}"
  rds_instance_type = "${var.rds_instance_type}"
  rds_family        = "${var.rds_family}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain               = "${var.domain}"
  sub_domain           = "${var.sub_domain}"
  rds_website_endpoint = "${module.compute.rds_endpoint}"
}

output "rds_endpoint"   { value = "${module.compute.rds_endpoint}" }
output "route53_record_fqdn_wp" { value = "${module.dns.route53_record_fqdn}" }
