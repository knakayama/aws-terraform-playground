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

output "s3_website_endpoint" { value = "${module.website.s3_website_endpoint}" }
output "route53_record_fqdn" { value = "${module.website.route53_record_fqdn}" }
