output "cf_domain_name" {
  value = "${aws_cloudfront_distribution.cf.domain_name}"
}
