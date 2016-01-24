variable "domain"        { }
variable "sub_domain"    { }
variable "web_public_ip" { }

resource "aws_route53_zone" "dns" {
  name   = "${var.domain}"
}

resource "aws_route53_record" "dns" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain}.${var.domain}"
  type    = "A"
  ttl     = 60
  records = ["${var.web_public_ip}"]
}

output "route53_record_fqdn" { value = "${aws_route53_record.dns.fqdn}" }
