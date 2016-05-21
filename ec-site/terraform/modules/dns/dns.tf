variable "vpc_id" {}

variable "azs" {}

variable "public_domain" {}

variable "private_domain" {}

variable "web_ap_admin_private_ips" {}

variable "web_ap_admin_sub_domain" {}

variable "web_ap_public_sub_domain" {}

variable "elb_admin_zone_ids" {}

variable "elb_admin_dns_names" {}

variable "elb_public_zone_ids" {}

variable "elb_public_dns_names" {}

variable "rds_endpoint" {}

variable "elasticache_endpoint" {}

variable "rds_sub_domain" {}

variable "elasticache_sub_domain" {}

variable "failover" {
  default = {
    "0" = "PRIMARY"
    "1" = "SECONDARY"
  }
}

resource "aws_route53_zone" "public" {
  name = "${var.public_domain}"
}

resource "aws_route53_health_check" "public_elb_admin" {
  count             = "${length(split(",", var.azs))}"
  fqdn              = "${element(split(",", var.elb_admin_dns_names), count.index)}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "public_elb_admin" {
  count           = "${length(split(",", var.azs))}"
  zone_id         = "${aws_route53_zone.public.zone_id}"
  name            = "${var.web_ap_admin_sub_domain}.${var.public_domain}"
  type            = "A"
  failover        = "${lookup(var.failover, count.index%2)}"
  health_check_id = "${element(aws_route53_health_check.public_elb_admin.*.id, count.index)}"
  set_identifier  = "${lower(lookup(var.failover, count.index%2))}"

  alias {
    name                   = "${element(split(",", var.elb_admin_dns_names), count.index)}"
    zone_id                = "${element(split(",", var.elb_admin_zone_ids), count.index)}"
    evaluate_target_health = true
  }
}

resource "aws_route53_health_check" "public_elb_public" {
  count             = "${length(split(",", var.azs))}"
  fqdn              = "${element(split(",", var.elb_public_dns_names), count.index)}"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = 3
  request_interval  = 30
}

resource "aws_route53_record" "public_elb_public" {
  count           = "${length(split(",", var.azs))}"
  zone_id         = "${aws_route53_zone.public.zone_id}"
  name            = "${var.web_ap_public_sub_domain}.${var.public_domain}"
  type            = "A"
  failover        = "${lookup(var.failover, count.index%2)}"
  health_check_id = "${element(aws_route53_health_check.public_elb_public.*.id, count.index)}"
  set_identifier  = "${lower(lookup(var.failover, count.index%2))}"

  alias {
    name                   = "${element(split(",", var.elb_public_dns_names), count.index)}"
    zone_id                = "${element(split(",", var.elb_public_zone_ids), count.index)}"
    evaluate_target_health = true
  }
}

resource "aws_route53_zone" "private" {
  name   = "${var.private_domain}"
  vpc_id = "${var.vpc_id}"
}

resource "aws_route53_record" "private_web_ap_admin" {
  count   = "${length(split(",", var.azs))}"
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${concat(var.web_ap_admin_sub_domain, count.index+1, ".", var.private_domain)}"
  type    = "A"
  ttl     = 60
  records = ["${element(split(",", var.web_ap_admin_private_ips), count.index)}"]
}

resource "aws_route53_record" "private_rds" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${concat(var.rds_sub_domain, ".", var.private_domain)}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.rds_endpoint}"]
}

resource "aws_route53_record" "private_elasticache" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "${concat(var.elasticache_sub_domain, ".", var.private_domain)}"
  type    = "CNAME"
  ttl     = 60
  records = ["${var.elasticache_endpoint}"]
}

output "web_ap_admin_private_fqdns" {
  value = "${join(", ", aws_route53_record.private_web_ap_admin.*.fqdn)}"
}

output "web_ap_admin_public_fqdn" {
  value = "${aws_route53_record.public_elb_admin.0.fqdn}"
}

output "web_ap_public_public_fqdn" {
  value = "${aws_route53_record.public_elb_public.0.fqdn}"
}

output "rds_fqdn" {
  value = "${aws_route53_record.private_rds.fqdn}"
}

output "elasticache_fqdn" {
  value = "${aws_route53_record.private_elasticache.fqdn}"
}
