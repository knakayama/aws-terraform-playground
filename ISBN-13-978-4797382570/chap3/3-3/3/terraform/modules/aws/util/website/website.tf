variable "name"        { default = "website" }
variable "policy_file" { }
variable "acl"         { }
variable "htmls"       { }
variable "domain"      { }
variable "sub_domain"  { }

variable "rel_path" {
  default = "../../../modules/aws/util/website/"
}

resource "template_file" "website_policy" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet_name = "${var.name}"
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = "${var.name}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.website_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(var.rel_path, element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

resource "template_file" "website_cloudfront" {
  template = "${file(concat(var.rel_path, "cloudfront.json.tpl"))}"
  #template = "${file(concat(var.rel_path, "cloudfront.json.bak.tpl"))}"

  vars {
    id               = "${var.name}"
    domain_name      = "${var.sub_domain}.${var.domain}"
    website_endpoint = "${aws_s3_bucket.website.website_endpoint}"
  }
}

resource "aws_cloudformation_stack" "website" {
  name = "${var.name}"
  template_body = "${template_file.website_cloudfront.rendered}"
}

## FIXME: not work
#resource "aws_cloudformation_stack" "website" {
#  name = "${var.name}"
#  template_body = "${template_file.website_cloudfront.rendered}"
#}

output "endpoint"       { value = "${aws_s3_bucket.website.website_endpoint}" }
output "domain"         { value = "${aws_s3_bucket.website.domain}" }
output "hosted_zone_id" { value = "${aws_s3_bucket.website.hosted_zone_id}" }
