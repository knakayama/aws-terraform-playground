variable "name"   { }
variable "region" { }

variable "policy_file" { }
variable "htmls"       { }
variable "acl"         { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "vpc_cidr"      { }
variable "public_subnet" { }

variable "domain"          { }
variable "sub_domain_s3"   { }
variable "sub_domain_web"  { }
variable "sub_domain_data" { }

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

  acl             = "${var.acl}"
  policy_file     = "${var.policy_file}"
  htmls           = "${var.htmls}"
  domain          = "${var.domain}"
  sub_domain_s3   = "${var.sub_domain_s3}"
  sub_domain_data = "${var.sub_domain_data}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain                = "${var.domain}"
  sub_domain_s3         = "${var.sub_domain_s3}"
  sub_domain_web        = "${var.sub_domain_web}"
  sub_domain_data       = "${var.sub_domain_data}"
  web_public_ip         = "${module.compute.web_public_ip}"
  website_endpoint_s3   = "${module.website.website_endpoint_s3}"
  website_endpoint_data = "${module.website.website_endpoint_data}"
}

output "website_endpoint_s3"      { value = "${module.website.website_endpoint_s3}" }
output "website_endpoint_data"    { value = "${module.website.website_endpoint_data}" }
output "route53_record_fqdn_s3"   { value = "${module.dns.route53_record_fqdn_s3}" }
output "route53_record_fqdn_web"  { value = "${module.dns.route53_record_fqdn_web}" }
output "route53_record_fqdn_data" { value = "${module.dns.route53_record_fqdn_data}" }
