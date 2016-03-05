variable "name"              { }
variable "region"            { }
variable "site_public_key"   { }
variable "atlas_environment" { }
variable "atlas_username"    { }
variable "atlas_aws_global"  { }
variable "atlas_token"       { }

variable "bastion_artifact_type"    { }
variable "bastion_artifact_name"    { }
variable "bastion_artifact_version" { }

variable "ec2_instance_type"   { }
variable "ec2_instance_ami_id" { }

variable "vpc_cidr"       { }
variable "public_subnet"  { }
variable "private_subnet" { }
variable "azs"            { }

variable "domain"      { }
variable "sub_domains" { }

provider "aws" {
  region     = "${var.region}"
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

  name           = "${var.name}"
  azs            = "${var.azs}"
  vpc_cidr       = "${var.vpc_cidr}"
  public_subnet  = "${var.public_subnet}"
  private_subnet = "${var.private_subnet}"
}

module "artifact_bastion" {
  source = "../../../modules/aws/util/artifact"

  type             = "${var.bastion_artifact_type}"
  region           = "${var.region}"
  atlas_username   = "${var.atlas_username}"
  artifact_name    = "${var.bastion_artifact_name}"
  artifact_version = "${var.bastion_artifact_version}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                    = "${var.name}"
  key_name                = "${aws_key_pair.site_key.key_name}"
  vpc_id                  = "${module.network.vpc_id}"
  azs                     = "${var.azs}"
  public_subnet_id        = "${module.network.public_subnet_id}"
  private_subnet_id       = "${module.network.private_subnet_id}"
  ec2_instance_type       = "${var.ec2_instance_type}"
  ec2_instance_ami_id     = "${var.ec2_instance_ami_id}"
  bastion_artifact_ami_id = "${module.artifact_bastion.ami_id}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain         = "${var.domain}"
  vpc_id         = "${module.network.vpc_id}"
  sub_domains    = "${var.sub_domains}"
  web_private_ip = "${module.compute.web_private_ip}"
  db_private_ip  = "${module.compute.db_private_ip}"
}

output "bastion_public_ip" { value = "${module.compute.bastion_public_ip}" }
output "web_private_ip"    { value = "${module.compute.web_private_ip}" }
output "db_private_ip"     { value = "${module.compute.db_private_ip}" }
