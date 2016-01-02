variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "rds_username"        { }
variable "rds_password"        { }
variable "rds_engine"          { }
variable "rds_engine_ver"      { }
variable "rds_instance_type"   { }
variable "rds_family"          { }

variable "azs"             { }
variable "vpc_cidr"        { }
variable "public_subnets"  { }
variable "private_subnets" { }

variable "domain"     { }
variable "sub_domain" { }

variable "max_size" { }
variable "min_size" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name            = "${var.name}"
  azs             = "${var.azs}"
  vpc_cidr        = "${var.vpc_cidr}"
  public_subnets  = "${var.public_subnets}"
  private_subnets = "${var.private_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  private_subnet_ids  = "${module.network.private_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  rds_username        = "${var.rds_username}"
  rds_password        = "${var.rds_password}"
  rds_engine          = "${var.rds_engine}"
  rds_engine_ver      = "${var.rds_engine_ver}"
  rds_instance_type   = "${var.rds_instance_type}"
  rds_family          = "${var.rds_family}"
  max_size            = "${var.max_size}"
  min_size            = "${var.min_size}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain       = "${var.domain}"
  sub_domain   = "${var.sub_domain}"
  elb_dns_name = "${module.compute.elb_dns_name}"
  elb_zone_id  = "${module.compute.elb_zone_id}"
}

output "elb_dns_name"         { value = "${module.compute.elb_dns_name}" }
output "rds_endpoint_master"  { value = "${module.compute.rds_endpoint_master}" }
output "rds_endpoint_replica" { value = "${module.compute.rds_endpoint_replica}" }
output "route53_record_fqdn"  { value = "${module.dns.route53_record_fqdn}" }
