variable "name" {}

variable "region" {}

variable "keypair" {}

variable "vpc_cidr" {}

variable "azs" {}

variable "public_subnets" {}

variable "private_subnets_web" {}

variable "private_subnets_db" {}

variable "web_ap_admin_type" {}

variable "web_ap_admin_ami_id" {}

variable "web_ap_public_type" {}

variable "web_ap_public_ami_id" {}

variable "web_ap_public_max_size" {}

variable "web_ap_public_min_size" {}

variable "rds_db_name" {}

variable "rds_master_username" {}

variable "rds_master_password" {}

variable "rds_class" {}

variable "elasticache_engine" {}

variable "elasticache_engine_ver" {}

variable "elasticache_type" {}

variable "public_domain" {}

variable "private_domain" {}

variable "web_ap_admin_sub_domain" {}

variable "web_ap_public_sub_domain" {}

variable "rds_sub_domain" {}

variable "elasticache_sub_domain" {}

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "keypair" {
  key_name   = "${var.name}"
  public_key = "${file(concat(path.module, "/keypair/", var.keypair))}"
}

module "remote_state" {
  source = "../modules/remote_state"

  region              = "${var.region}"
  remote_state_bucket = "${var.name}-tfstate"
}

module "network" {
  source = "../modules/network"

  name                = "${var.name}"
  vpc_cidr            = "${var.vpc_cidr}"
  azs                 = "${var.azs}"
  public_subnets      = "${var.public_subnets}"
  private_subnets_web = "${var.private_subnets_web}"
  private_subnets_db  = "${var.private_subnets_db}"
}

module "compute" {
  source = "../modules/compute"

  name                   = "${var.name}"
  key_name               = "${aws_key_pair.keypair.key_name}"
  azs                    = "${var.azs}"
  vpc_id                 = "${module.network.vpc_id}"
  public_subnet_ids      = "${module.network.public_subnet_ids}"
  private_subnet_ids_web = "${module.network.private_subnet_ids_web}"
  web_ap_admin_type      = "${var.web_ap_admin_type}"
  web_ap_admin_ami_id    = "${var.web_ap_admin_ami_id}"
  web_ap_public_type     = "${var.web_ap_public_type}"
  web_ap_public_ami_id   = "${var.web_ap_public_ami_id}"
  web_ap_public_max_size = "${var.web_ap_public_max_size}"
  web_ap_public_min_size = "${var.web_ap_public_min_size}"
}

module "db" {
  source = "../modules/db"

  name                   = "${var.name}"
  azs                    = "${var.azs}"
  vpc_id                 = "${module.network.vpc_id}"
  private_subnet_ids_db  = "${module.network.private_subnet_ids_db}"
  web_ap_admin_sg_id     = "${module.compute.web_ap_admin_sg_id}"
  web_ap_public_sg_id    = "${module.compute.web_ap_public_sg_id}"
  rds_db_name            = "${var.name}"
  rds_master_username    = "${var.rds_master_username}"
  rds_master_password    = "${var.rds_master_password}"
  rds_class              = "${var.rds_class}"
  elasticache_engine     = "${var.elasticache_engine}"
  elasticache_engine_ver = "${var.elasticache_engine_ver}"
  elasticache_type       = "${var.elasticache_type}"
}

module "dns" {
  source = "../modules/dns"

  vpc_id                   = "${module.network.vpc_id}"
  azs                      = "${var.azs}"
  public_domain            = "${var.public_domain}"
  private_domain           = "${var.private_domain}"
  web_ap_admin_private_ips = "${module.compute.web_ap_admin_private_ips}"
  web_ap_admin_sub_domain  = "${var.web_ap_admin_sub_domain}"
  web_ap_public_sub_domain = "${var.web_ap_public_sub_domain}"
  elb_admin_dns_names      = "${module.compute.elb_admin_dns_names}"
  elb_public_dns_names     = "${module.compute.elb_public_dns_names}"
  elb_admin_zone_ids       = "${module.compute.elb_admin_zone_ids}"
  elb_public_zone_ids      = "${module.compute.elb_public_zone_ids}"
  rds_endpoint             = "${module.db.rds_endpoint}"
  rds_sub_domain           = "${var.rds_sub_domain}"
  elasticache_endpoint     = "${module.db.elasticache_endpoint}"
  elasticache_sub_domain   = "${var.elasticache_sub_domain}"
}

output "remote_state_bucket" {
  value = "${module.remote_state.remote_state_bucket}"
}

output "elb_admin_dns_names" {
  value = "${replace(module.compute.elb_admin_dns_names, ",", ", ")}"
}

output "elb_public_dns_names" {
  value = "${replace(module.compute.elb_public_dns_names, ",", ", ")}"
}

output "web_ap_admin_private_fqdns" {
  value = "${module.dns.web_ap_admin_private_fqdns}"
}

output "web_ap_admin_public_fqdn" {
  value = "${module.dns.web_ap_admin_public_fqdn}"
}

output "web_ap_public_public_fqdn" {
  value = "${module.dns.web_ap_public_public_fqdn}"
}

output "rds_fqdn" {
  value = "${module.dns.rds_fqdn}"
}

output "elasticache_endpoint" {
  value = "${module.dns.elasticache_fqdn}"
}
