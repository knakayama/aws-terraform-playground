variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "azs"            { }
variable "vpc_cidr"       { }
variable "public_subnets" { }

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

  name           = "${var.name}"
  azs            = "${var.azs}"
  vpc_cidr       = "${var.vpc_cidr}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.network.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
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

output "elb_dns_name"        { value = "${module.compute.elb_dns_name}" }
output "route53_record_fqdn" { value = "${module.dns.route53_record_fqdn}" }
