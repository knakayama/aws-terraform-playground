variable "name"        { }
variable "region"      { }
variable "policy_file" { }
variable "htmls"       { }
variable "acl"         { }
variable "domain"      { }
variable "sub_domain"  { }

provider "aws" {
  region = "${var.region}"
}

module "website" {
  source = "../../../modules/aws/util/website"

  name        = "${var.name}"
  acl         = "${var.acl}"
  policy_file = "${var.policy_file}"
  htmls       = "${var.htmls}"
  domain      = "${var.domain}"
  sub_domain  = "${var.sub_domain}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain                 = "${var.domain}"
  sub_domain             = "${var.sub_domain}"
  website_domain         = "${module.website.domain}"
  website_hosted_zone_id = "${module.website.hosted_zone_id}"
}

output "route53_fqdn"        { value = "${module.dns.fqdn}" }
output "website_endpoint" { value = "${module.website.endpoint}" }
