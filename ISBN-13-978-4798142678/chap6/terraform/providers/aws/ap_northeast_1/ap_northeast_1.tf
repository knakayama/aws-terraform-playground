variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "vpc_cidr"      { }
variable "az"            { }
variable "public_subnet" { }

variable "acl"         { }
variable "policy_file" { }
variable "htmls"       { }

variable "domain"    { }
variable "mt_domain" { }
variable "s3_domain" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "site_key"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name          = "${var.name}"
  vpc_cidr      = "${var.vpc_cidr}"
  az            = "${var.az}"
  public_subnet = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

module "website" {
  source = "../../../modules/aws/util/website"

  acl         = "${var.acl}"
  policy_file = "${var.policy_file}"
  htmls       = "${var.htmls}"
  domain      = "${var.domain}"
  s3_domain   = "${var.s3_domain}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain              = "${var.domain}"
  mt_domain           = "${var.mt_domain}"
  s3_domain           = "${var.s3_domain}"
  web_public_ip       = "${module.compute.web_public_ip}"
  s3_website_endpoint = "${module.website.s3_website_endpoint}"
  s3_website_domain   = "${module.website.s3_website_domain}"
  s3_hosted_zone      = "${module.website.s3_hosted_zone}"
}

output "s3_website_endpoint"    { value = "${module.website.s3_website_endpoint}" }
output "route53_record_fqdn_mt" { value = "${module.dns.route53_record_fqdn_mt}" }
output "route53_record_fqdn_s3" { value = "${module.dns.route53_record_fqdn_s3}" }
