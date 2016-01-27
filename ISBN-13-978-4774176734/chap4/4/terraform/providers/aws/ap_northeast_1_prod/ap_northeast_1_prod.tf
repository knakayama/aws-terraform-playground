variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "vpc_cidr"       { }
variable "public_subnets" { }
variable "azs"            { }

variable "domain"      { }
variable "sub_domains" { }

provider "aws" {
  region     = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  azs            = "${var.azs}"
  vpc_cidr       = "${var.vpc_cidr}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                 = "${var.name}"
  key_name             = "${aws_key_pair.site_key.key_name}"
  vpc_id               = "${module.network.vpc_id}"
  azs                  = "${var.azs}"
  public_subnet_ids    = "${module.network.public_subnet_ids}"
  web_instance_type    = "${var.web_instance_type}"
  web_instance_ami_id  = "${var.web_instance_ami_id}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  name             = "${var.name}"
  domain           = "${var.domain}"
  vpc_id           = "${module.network.vpc_id}"
  sub_domains      = "${var.sub_domains}"
  web_private_ips  = "${module.compute.web_private_ips}"
}

output "route53_fqdns"   { value = "${module.dns.fqdns}" }
output "web_public_ips"  { value = "${module.compute.web_public_ips}" }
output "web_private_ips" { value = "${module.compute.web_private_ips}" }
