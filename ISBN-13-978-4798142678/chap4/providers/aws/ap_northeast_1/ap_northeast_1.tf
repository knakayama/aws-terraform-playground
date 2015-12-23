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
  policy_file = "${var.policy_file}"
  htmls       = "${var.htmls}"
  domain      = "${var.domain}"
  sub_domain  = "${var.sub_domain}"
}

output "s3_website_endpoint_redirected_to" { value = "${module.website.s3_website_endpoint_redirected_to}" }
output "s3_website_endpoint_redirected"    { value = "${module.website.s3_website_endpoint_redirected}" }
output "route53_record_fqdn" { value = "${module.website.route53_record_fqdn}" }
