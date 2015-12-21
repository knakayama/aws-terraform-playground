variable "name"          { default = "website" }
variable "policy_file"   { }
variable "acl"           { }
variable "htmls"         { }
variable "domain"        { }
variable "sub_domain"    { }
variable "web_public_ip" { }

variable "rel_path"       { default = "../../../modules/aws/util/website/" }

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

resource "aws_route53_zone" "website" {
  name = "${var.domain}"
}

resource "aws_route53_health_check" "website_primary" {
  fqdn              = "${var.sub_domain}.${var.domain}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "website_primary" {
  zone_id         = "${aws_route53_zone.website.zone_id}"
  name            = "${var.sub_domain}"
  type            = "A"
  failover        = "PRIMARY"
  health_check_id = "${aws_route53_health_check.website_primary.id}"
  set_identifier  = "blog-primary"
  ttl             = 60
  records         = ["${var.web_public_ip}"]
}

resource "aws_route53_record" "website_secondary" {
  zone_id        = "${aws_route53_zone.website.zone_id}"
  name           = "${var.sub_domain}"
  type           = "A"
  failover       = "SECONDARY"
  set_identifier = "blog-secondary"

  alias {
    name                   = "${aws_s3_bucket.website.website_domain}"
    zone_id                = "${aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "s3_website_endpoint"  { value = "${aws_s3_bucket.website.website_endpoint}" }
output "route53_record_fqdns" { value = "${join(",", aws_route53_record.website_primary.fqdn, aws_route53_record.website_secondary.fqdn)}" }
