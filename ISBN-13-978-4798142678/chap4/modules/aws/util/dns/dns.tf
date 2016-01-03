variable "domain"                            { }
variable "sub_domain"                        { }
variable "website_endpoint_redirected_to"    { }
variable "website_domain_redirected"         { }
variable "website_hosted_zone_id_redirected" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns_redirected_to" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.website_endpoint_redirected_to}"]
}

resource "aws_route53_record" "dns_redirected" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name    = "${var.website_domain_redirected}"
    zone_id = "${var.website_hosted_zone_id_redirected}"
    evaluate_target_health = false
  }
}

output "fqdn_redirected_to" { value = "${aws_route53_record.dns_redirected_to.fqdn}" }
output "fqdn_redirected"    { value = "${aws_route53_record.dns_redirected.fqdn}" }
