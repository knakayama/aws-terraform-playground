variable "name"          { default = "website" }
variable "policy_file"   { }
variable "acl"           { }
variable "htmls"         { }

variable "rel_path" {
  default = "../../../modules/aws/util/website/"
}

resource "template_file" "website_policy" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet = "${var.name}"
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = "${var.name}"
  acl           = "${var.acl}"
  policy        = "${template_file.website_policy.rendered}"
  force_destroy = true

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

output "endpoint"       { value = "${aws_s3_bucket.website.website_endpoint}" }
output "domain"         { value = "${aws_s3_bucket.website.website_domain}" }
output "hosted_zone_id" { value = "${aws_s3_bucket.website.hosted_zone_id}" }
