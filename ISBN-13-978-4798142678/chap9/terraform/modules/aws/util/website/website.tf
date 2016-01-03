variable "acl"         { }
variable "policy_file" { }
variable "htmls"       { }
variable "domain"      { }
variable "s3_domain"   { }

resource "template_file" "website" {
  template = "${file(concat(path.module, "/", var.policy_file))}"

  vars {
    backet_name = "${var.s3_domain}.${var.domain}"
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = "${var.s3_domain}.${var.domain}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.website.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(path.module, "/", element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

output "s3_website_endpoint" { value = "${aws_s3_bucket.website.website_endpoint}" }
output "s3_website_domain"   { value = "${aws_s3_bucket.website.website_domain}" }
output "s3_hosted_zone"      { value = "${aws_s3_bucket.website.hosted_zone_id}" }
output "s3_bucket_id"        { value = "${aws_s3_bucket.website.id}" }
