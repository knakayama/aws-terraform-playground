variable "domain"       { }
variable "sub_domain"   { }
variable "elb_dns_name" { }
variable "elb_zone_id"  { }

resource "aws_route53_zone" "dns" {
  name   = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${sub_domain}"
  type    = "A"

  alias {
    name    = "${var.elb_dns_name}"
    zone_id = "${var.elb_zone_id}"
    evaluate_target_health = true
  }
}

output "route53_record_fqdn" { value = "${aws_route53_record.dns.fqdn}" }
