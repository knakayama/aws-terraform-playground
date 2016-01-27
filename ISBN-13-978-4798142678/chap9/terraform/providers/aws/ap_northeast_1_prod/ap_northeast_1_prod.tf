variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "vpc_cidr"        { }
variable "azs"             { }
variable "public_subnet"   { }
variable "private_subnets" { }

variable "acl"         { }
variable "policy_file" { }
variable "htmls"       { }

variable "domain"    { }
variable "wp_domain" { }
variable "s3_domain" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "rds_username"        { }
variable "rds_password"        { }
variable "rds_engine"          { }
variable "rds_engine_ver"      { }
variable "rds_instance_type"   { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "site_key"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name            = "${var.name}"
  vpc_cidr        = "${var.vpc_cidr}"
  azs             = "${var.azs}"
  public_subnet   = "${var.public_subnet}"
  private_subnets = "${var.private_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet       = "${var.public_subnet}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  private_subnet_ids  = "${module.network.private_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  rds_username        = "${var.rds_username}"
  rds_password        = "${var.rds_password}"
  rds_engine          = "${var.rds_engine}"
  rds_engine_ver      = "${var.rds_engine_ver}"
  rds_instance_type   = "${var.rds_instance_type}"
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
  wp_domain           = "${var.wp_domain}"
  s3_domain           = "${var.s3_domain}"
  web_public_ip       = "${module.compute.web_public_ip}"
  s3_website_endpoint = "${module.website.s3_website_endpoint}"
  s3_website_domain   = "${module.website.s3_website_domain}"
  s3_hosted_zone      = "${module.website.s3_hosted_zone}"
}

module "monitoring" {
  source = "../../../modules/aws/monitoring"

  name            = "${var.name}"
  web_instance_id = "${module.compute.web_instance_id}"
  rds_instance_id = "${module.compute.rds_instance_id}"
  s3_bucket_id    = "${module.website.s3_bucket_id}"
}

output "s3_website_endpoint"    { value = "${module.website.s3_website_endpoint}" }
output "route53_record_fqdn_wp" { value = "${module.dns.route53_record_fqdn_wp}" }
output "route53_record_fqdn_s3" { value = "${module.dns.route53_record_fqdn_s3}" }
