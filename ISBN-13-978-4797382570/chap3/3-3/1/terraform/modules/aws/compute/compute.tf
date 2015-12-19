variable "name"        { }
variable "policy_file" { }
variable "acl"         { }
variable "htmls"       { }

module "s3" {
  source = "./s3"

  name        = "${var.name}-s3"
  acl         = "${var.acl}"
  policy_file = "${var.policy_file}"
  htmls       = "${var.htmls}"
}

output "s3_website_endpoint" { value = "${module.s3.website_endpoint}" }
