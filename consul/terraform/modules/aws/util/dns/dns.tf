variable "domain"          { }
variable "sub_domains"     { }
variable "vpc_ids"         { }
variable "web_private_ips" { }

resource "aws_route53_zone" "dns" {
  count  = "${length(split(",", var.sub_domains))}"
  name   = "${var.domain}"
  vpc_id = "${element(split(",", var.vpc_ids), count.index)}"
}

resource "aws_route53_record" "dns" {
  count   = "${length(split(",", var.sub_domains))}"
  zone_id = "${element(aws_route53_zone.dns.*.id, count.index)}"
  name    = "${element(split(",", var.sub_domains), count.index)}.${var.domain}"
  type    = "A"
  ttl     = 60
  records = ["${element(split(",", var.web_private_ips), count.index)}"]
}

output "web_fqdns" { value = "${join(",", aws_route53_record.dns.*.fqdn)}" }
