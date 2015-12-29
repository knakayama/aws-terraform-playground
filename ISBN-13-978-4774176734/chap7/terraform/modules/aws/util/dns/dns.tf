variable "domain"               { }
variable "sub_domain"           { }
variable "rds_website_endpoint" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.rds_website_endpoint}"]
}

output "route53_record_fqdn" { value = "${aws_route53_record.dns.fqdn}" }
