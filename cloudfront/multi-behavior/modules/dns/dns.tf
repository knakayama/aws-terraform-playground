resource "aws_route53_zone" "dns" {
  name = "${var.domain_config["domain"]}"
}

resource "aws_route53_record" "bastion" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.domain_config["bastion_sub_domain"]}"
  type    = "A"
  ttl     = 300
  records = ["${var.bastion_public_ip}"]
}

resource "aws_route53_record" "elb" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.domain_config["elb_sub_domain"]}"
  type    = "A"

  alias {
    name                   = "${var.elb_config["dns_name"]}"
    zone_id                = "${var.elb_config["zone_id"]}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cf" {
  zone_id = "${aws_route53_zone.dns.zone_id}"
  name    = "${var.domain_config["cf_sub_domain"]}"
  type    = "A"

  alias {
    name                   = "${var.cf_config["domain_name"]}"
    zone_id                = "${var.cf_config["hosted_zone_id"]}"
    evaluate_target_health = false
  }
}
