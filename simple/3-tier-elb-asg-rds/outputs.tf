output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "rds_address" {
  value = "${aws_db_instance.rds.address}"
}
