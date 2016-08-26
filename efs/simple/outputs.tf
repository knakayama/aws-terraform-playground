output "public_ips" {
  value = "${join(", ", aws_spot_instance_request.web.*.public_ip)}"
}

output "efs_id" {
  value = "${aws_efs_file_system.efs.id}"
}

output "efs_mount_id" {
  value = "${aws_efs_mount_target.efs.id}"
}

output "efs_dns_name" {
  value = "${aws_efs_mount_target.efs.dns_name}"
}

output "efs_network_interface_id" {
  value = "${aws_efs_mount_target.efs.network_interface_id}"
}
