output "parameter_group_id" {
  value = "${aws_redshift_parameter_group.pg.id}"
}

output "subnet_group_id" {
  value = "${aws_redshift_subnet_group.sg.id}"
}

output "endpoint" {
  value = "${aws_redshift_cluster.cluster.endpoint}"
}

output "public_ip" {
  value = "${aws_spot_instance_request.ec2.public_ip}"
}
