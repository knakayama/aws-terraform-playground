variable "domain"        { }
variable "sub_domain"    { }
variable "web_public_ip" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  name    = "${var.sub_domain}.${var.domain}"
  zone_id = "${aws_route53_zone.dns.zone_id}"
  type    = "A"
  ttl     = 60
  records = ["${var.web_public_ip}"]
}

output "route53_fqdn" { value = "${aws_route53_record.dns.fqdn}" }
