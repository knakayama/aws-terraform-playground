variable "name"              { }
variable "region"            { }
variable "site_public_key"   { }
variable "atlas_token"       { }
variable "atlas_username"    { }
variable "atlas_aws_global"  { }
variable "atlas_environment" { }

variable "vpc_cidr"      { }
variable "az"            { }
variable "public_subnet" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "domain"     { }
variable "sub_domain" { }

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

  name          = "${var.name}"
  az            = "${var.az}"
  vpc_cidr      = "${var.vpc_cidr}"
  public_subnet = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.network.vpc_id}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

module "dns" {
  source = "../../../modules/aws/utils/dns"

  domain        = "${var.domain}"
  sub_domain    = "${var.sub_domain}"
  web_public_ip = "${module.compute.web_public_ip}"
}

output "web_public_ip" { value = "${module.compute.web_public_ip}" }
output "route53_fqdn"  { value = "${module.dns.route53_fqdn}" }
