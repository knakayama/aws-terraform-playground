variable "acl"         { }
variable "policy_file" { }
variable "htmls"       { }
variable "domain"      { }
variable "sub_domain"  { }

variable "rel_path" {
  default = "../../../modules/aws/util/website/"
}

resource "template_file" "website_redirected_to" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet_name = "${var.sub_domain}.${var.domain}"
  }
}

resource "template_file" "website_redirected" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet_name = "${var.domain}"
  }
}

resource "aws_s3_bucket" "website_redirected_to" {
  bucket        = "${var.sub_domain}.${var.domain}"
  acl           = "${var.acl}"
  policy        = "${template_file.website_redirected_to.rendered}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "website_redirected" {
  bucket        = "${var.domain}"
  acl           = "${var.acl}"
  policy        = "${template_file.website_redirected.rendered}"
  force_destroy = true

  website {
    redirect_all_requests_to = "${var.sub_domain}.${var.domain}"
  }
}

resource "aws_s3_bucket_object" "website_redirected" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website_redirected_to.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(var.rel_path, element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

output "endpoint_redirected_to"    { value = "${aws_s3_bucket.website_redirected_to.website_endpoint}" }
output "domain_redirected"         { value = "${aws_s3_bucket.website_redirected.website_domain}" }
output "hosted_zone_id_redirected" { value = "${aws_s3_bucket.website_redirected.hosted_zone_id}" }
