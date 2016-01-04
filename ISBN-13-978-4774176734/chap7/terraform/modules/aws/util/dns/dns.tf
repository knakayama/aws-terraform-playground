variable "domain"       { }
variable "sub_domain"   { }
variable "rds_endpoint" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.rds_endpoint}"]
}

output "fqdn_rds" { value = "${aws_route53_record.dns.fqdn_rds}" }
