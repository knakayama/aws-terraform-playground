variable "domain"              { }
variable "wp_domain"           { }
variable "s3_domain"           { }
variable "web_public_ip"       { }
variable "s3_website_endpoint" { }
variable "s3_website_domain"   { }
variable "s3_hosted_zone"      { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns_wp" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.wp_domain}"
  type    = "A"
  ttl     = 60
  records = ["${var.web_public_ip}"]
}

resource "aws_route53_record" "dns_s3" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.s3_domain}"
  type    = "A"

  alias {
    name                   = "${var.s3_website_domain}"
    zone_id                = "${var.s3_hosted_zone}"
    evaluate_target_health = false
  }
}

output "route53_record_fqdn_wp" { value = "${aws_route53_record.dns_wp.fqdn}" }
output "route53_record_fqdn_s3" { value = "${aws_route53_record.dns_s3.fqdn}" }
