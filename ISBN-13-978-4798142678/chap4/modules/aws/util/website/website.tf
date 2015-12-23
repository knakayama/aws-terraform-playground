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
  force_destroy = true
  policy        = "${template_file.website_redirected_to.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "website_redirected" {
  bucket        = "${var.domain}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.website_redirected.rendered}"

  website {
    redirect_all_requests_to = "${var.sub_domain}.${var.domain}"
  }
}

resource "aws_s3_bucket_object" "website_redirected_to" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website_redirected_to.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(var.rel_path, element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

resource "aws_route53_zone" "website" {
  name = "${var.domain}"
}

resource "aws_route53_record" "website_redirected_to" {
  zone_id = "${aws_route53_zone.website.zone_id}"
  name    = "${var.sub_domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_s3_bucket.website_redirected_to.website_endpoint}"]
}

resource "aws_route53_record" "website_redirected" {
  zone_id = "${aws_route53_zone.website.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.website_redirected_to.website_domain}"
    zone_id                = "${aws_s3_bucket.website_redirected_to.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "s3_website_endpoint_redirected_to" { value = "${aws_s3_bucket.website_redirected_to.website_endpoint}" }
output "s3_website_endpoint_redirected"    { value = "${aws_s3_bucket.website_redirected.website_endpoint}" }
output "route53_record_fqdn" { value = "${aws_route53_record.website_redirected_to.fqdn}" }
