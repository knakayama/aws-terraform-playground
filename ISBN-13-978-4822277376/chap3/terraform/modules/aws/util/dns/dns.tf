variable "domain"                { }
variable "sub_domain_s3"         { }
variable "sub_domain_web"        { }
variable "sub_domain_data"       { }
variable "web_public_ip"         { }
variable "website_endpoint_s3"   { }
variable "website_endpoint_data" { }

resource "aws_route53_zone" "dns" {
  name = "${var.domain}"
}

resource "aws_route53_record" "dns_s3" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain_s3}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.website_endpoint_s3}"]
}

resource "aws_route53_record" "dns_data" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain_data}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.website_endpoint_data}"]
}

resource "aws_route53_record" "dns_web" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.sub_domain_web}.${var.domain}"
  type    = "A"
  ttl     = 300
  records = ["${var.web_public_ip}"]
}

output "route53_record_fqdn_s3"   { value = "${aws_route53_record.dns_s3.fqdn}" }
output "route53_record_fqdn_web"  { value = "${aws_route53_record.dns_web.fqdn}" }
output "route53_record_fqdn_data" { value = "${aws_route53_record.dns_data.fqdn}" }
