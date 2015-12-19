variable "name"        { }
variable "region"      { }
variable "policy_file" { }
variable "htmls"       { }
variable "acl"         { }

provider "aws" {
  region = "${var.region}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name        = "${var.name}"
  acl         = "${var.acl}"
  policy_file = "${var.policy_file}"
  htmls       = "${var.htmls}"
}

output "s3_website_endpoint" { value = "${module.compute.s3_website_endpoint}" }
