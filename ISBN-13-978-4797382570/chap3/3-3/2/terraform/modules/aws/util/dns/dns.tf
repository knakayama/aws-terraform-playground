variable "domain"                 { }
variable "sub_domain"             { }
variable "website_domain"         { }
variable "website_hosted_zone_id" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain}.${var.domain}"
  type    = "A"

  alias {
    name    = "${var.website_domain}"
    zone_id = "${var.website_hosted_zone_id}"
    evaluate_target_health = false
  }
}

output "record_fqdn" { value = "${aws_route53_record.dns.fqdn}" }
