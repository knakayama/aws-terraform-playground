variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "public_subnets"  { }
variable "private_subnets" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "rds_username"      { }
variable "rds_password"      { }
variable "rds_engine"        { }
variable "rds_engine_ver"    { }
variable "rds_instance_type" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name             = "${var.name}"
  vpc_cidr         = "${var.vpc_cidr}"
  azs              = "${var.azs}"
  public_subnets   = "${var.public_subnets}"
  private_subnets  = "${var.private_subnets}"
  web_instance_ids = "${module.compute.web_instance_ids}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  public_subnets      = "${var.public_subnets}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  private_subnet_ids  = "${module.network.private_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  rds_username        = "${var.rds_username}"
  rds_password        = "${var.rds_password}"
  rds_engine          = "${var.rds_engine}"
  rds_engine_ver      = "${var.rds_engine_ver}"
  rds_instance_type   = "${var.rds_instance_type}"
  elb_sg_id           = "${module.network.elb_sg_id}"
}

output "elb_dns_name" { value = "${module.network.elb_dns_name}" }
