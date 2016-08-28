output "public_ips" {
  value = "${join(", ", aws_instance.web.*.public_ip)}"
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "elb_id" {
  value = "${aws_elb.elb.id}"
}
