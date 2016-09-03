output "public_ip_ec2_1" {
  value = "${aws_instance.ec2_1.public_ip}"
}

output "private_ip_ec2_1" {
  value = "${aws_instance.ec2_1.private_ip}"
}

output "public_ip_ec2_2" {
  value = "${aws_instance.ec2_2.public_ip}"
}

output "private_ip_ec2_2" {
  value = "${aws_instance.ec2_2.private_ip}"
}

output "endpoint" {
  value = "${aws_db_instance.rds.endpoint}"
}
