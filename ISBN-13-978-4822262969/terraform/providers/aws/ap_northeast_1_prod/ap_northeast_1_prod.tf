variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "private_subnets" { }
variable "public_subnets"  { }

variable "bastion_instance_type"   { }
variable "bastion_instance_ami_id" { }
variable "nat_instance_type"       { }
variable "nat_instance_ami_id"     { }

variable "mysql_instance_type"   { }
variable "mysql_instance_ami_id" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "site_key"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name                    = "${var.name}"
  vpc_cidr                = "${var.vpc_cidr}"
  azs                     = "${var.azs}"
  region                  = "${var.region}"
  private_subnets         = "${var.private_subnets}"
  public_subnets          = "${var.public_subnets}"
  key_name                = "${aws_key_pair.site_key.key_name}"
  bastion_instance_type   = "${var.bastion_instance_type}"
  bastion_instance_ami_id = "${var.bastion_instance_ami_id}"
  nat_instance_type       = "${var.nat_instance_type}"
  nat_instance_ami_id     = "${var.nat_instance_ami_id}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                  = "${var.name}"
  vpc_id                = "${module.network.vpc_id}"
  vpc_cidr              = "${var.vpc_cidr}"
  private_subnet_ids    = "${module.network.private_subnet_ids}"
  public_subnets        = "${var.public_subnets}"
  key_name              = "${aws_key_pair.site_key.key_name}"
  mysql_instance_type   = "${var.mysql_instance_type}"
  mysql_instance_ami_id = "${var.mysql_instance_ami_id}"
  bastion_user          = "${module.network.bastion_user}"
  bastion_public_ip     = "${module.network.bastion_public_ip}"
}

output "configuration" {
  value = <<CONFIGURATION

Bastion:
  bastion_user:       "${module.network.bastion_user}"
  bastion_private_ip: "${module.network.bastion_private_ip}"
  bastion_public_ip:  "${module.network.bastion_public_ip}"

NAT:
  nat_private_ips:  "${module.network.nat_private_ips}"
  nat_public_ips:   "${module.network.nat_public_ips}"

DB:
  mysql_private_ips: "${module.compute.mysql_private_ips}"

CONFIGURATION
}
