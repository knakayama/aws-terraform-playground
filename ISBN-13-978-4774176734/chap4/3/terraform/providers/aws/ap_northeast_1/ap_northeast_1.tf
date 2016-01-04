variable "name"   { }
variable "region" { }

variable "policy_file" { }
variable "htmls"       { }
variable "acl"         { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "vpc_cidr"      { }
variable "public_subnet" { }

variable "domain"     { }
variable "sub_domain" { }

provider "aws" {
  region = "${var.region}"
}

module "network" {
  source = "../../../modules/aws/network"

  name          = "${var.name}"
  vpc_cidr      = "${var.vpc_cidr}"
  public_subnet = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

module "website" {
  source = "../../../modules/aws/util/website"

  name        = "${var.name}"
  acl         = "${var.acl}"
  htmls       = "${var.htmls}"
  policy_file = "${var.policy_file}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain                 = "${var.domain}"
  sub_domain             = "${var.sub_domain}"
  web_public_ip          = "${module.compute.web_public_ip}"
  website_domain         = "${module.website.domain}"
  website_hosted_zone_id = "${module.website.hosted_zone_id}"
}

output "website_endpoint" { value = "${module.website.endpoint}" }
output "route53_fqdns"    { value = "${module.dns.fqdns}" }
