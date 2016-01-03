variable "domain"                 { }
variable "sub_domain"             { }
variable "web_public_ip"          { }
variable "website_domain"         { }
variable "website_hosted_zone_id" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_health_check" "dns_primary" {
  fqdn              = "${var.sub_domain}.${var.domain}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "dns_primary" {
  zone_id         = "${aws_route53_zone.dns.zone_id}"
  name            = "${var.sub_domain}"
  type            = "A"
  failover        = "PRIMARY"
  health_check_id = "${aws_route53_health_check.dns_primary.id}"
  set_identifier  = "blog-primary"
  ttl             = 60
  records         = ["${var.web_public_ip}"]
}

resource "aws_route53_record" "dns_secondary" {
  zone_id        = "${aws_route53_zone.dns.zone_id}"
  name           = "${var.sub_domain}"
  type           = "A"
  failover       = "SECONDARY"
  set_identifier = "blog-secondary"

  alias {
    name    = "${var.website_domain}"
    zone_id = "${var.website_hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "record_fqdns" { value = "${join(",", aws_route53_record.dns_primary.fqdn, aws_route53_record.dns_secondary.fqdn)}" }
