variable "name"              { }
variable "region"            { }
variable "site_public_key"   { }
variable "atlas_environment" { }
variable "atlas_username"    { }
variable "atlas_aws_global"  { }
variable "atlas_token"       { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "public_subnets"  { }
variable "private_subnets" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "rds_database_name"   { }
variable "rds_master_username" { }
variable "rds_master_password" { }
variable "rds_instance_class"  { }

provider "aws" {
  region = "${var.region}"
}

atlas {
  name = "${var.atlas_username}/${var.atlas_environment}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

resource "terraform_remote_state" "aws_global" {
  backend = "atlas"

  config {
    name = "${var.atlas_username}/${var.atlas_aws_global}"
  }

  lifecycle { create_before_destroy = true }
}

module "network" {
  source = "../../../modules/aws/network"

  name             = "${var.name}"
  vpc_cidr         = "${var.vpc_cidr}"
  azs              = "${var.azs}"
  public_subnets   = "${var.public_subnets}"
  private_subnets  = "${var.private_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

module "database" {
  source = "../../../modules/aws/database"

  name                  = "${var.name}"
  azs                   = "${var.azs}"
  vpc_id                = "${module.network.vpc_id}"
  web_security_group_id = "${module.compute.web_security_group_id}"
  private_subnet_ids    = "${module.network.private_subnet_ids}"
  rds_database_name     = "${var.rds_database_name}"
  rds_master_username   = "${var.rds_master_username}"
  rds_master_password   = "${var.rds_master_password}"
  rds_instance_class    = "${var.rds_instance_class}"
}

output "elb_dns_name"   { value = "${module.compute.elb_dns_name}" }
output "web_public_ips" { value = "${module.compute.web_public_ips}" }
output "rds_endpoints"  { value = "${module.database.rds_endpoints}" }
