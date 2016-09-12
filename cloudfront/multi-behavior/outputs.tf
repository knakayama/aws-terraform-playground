output "bastion_public_ip" {
  value = "${aws_eip.eip.public_ip}"
}

output "elb_config" {
  value = "${merge(map("dns_name", "${aws_elb.elb.dns_name}"), map("zone_id", "${aws_elb.elb.zone_id}"))}"
}

output "cf_config" {
  value = "${merge(map("domain_name", "${aws_cloudfront_distribution.cf.domain_name}"),map("hosted_zone_id", "${aws_cloudfront_distribution.cf.hosted_zone_id}"))}"
}
