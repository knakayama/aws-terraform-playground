variable "region"      { }

variable "acl"         { }
variable "policy_file" { }
variable "htmls"       { }

variable "domain"      { }
variable "sub_domain"  { }

provider "aws" {
  region = "${var.region}"
}

module "website" {
  source = "../../../modules/aws/util/website"

  acl         = "${var.acl}"
  htmls       = "${var.htmls}"
  policy_file = "${var.policy_file}"
  domain      = "${var.domain}"
  sub_domain  = "${var.sub_domain}"
}

module "dns" {
  source = "../../../modules/aws/util/dns"

  domain                            = "${var.domain}"
  sub_domain                        = "${var.sub_domain}"
  website_endpoint_redirected_to    = "${module.website.endpoint_redirected_to}"
  website_domain_redirected         = "${module.website.domain_redirected}"
  website_hosted_zone_id_redirected = "${module.website.hosted_zone_id_redirected}"
}

output "website_endpoint_redirected_to" { value = "${module.website.endpoint_redirected_to}" }
output "route53_fqdn_redirected"        { value = "${module.dns.fqdn_redirected}" }
output "route53_fqdn_redirected_to"     { value = "${module.dns.fqdn_redirected_to}" }
