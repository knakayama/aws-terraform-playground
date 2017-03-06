output "efs_ids" {
  value = "${join(", ", aws_efs_file_system.efs.*.id)}"
}

output "efs_mount_id" {
  value = "${join(", ", aws_efs_mount_target.efs.*.id)}"
}

output "efs_dns_name" {
  value = "${join(", ", aws_efs_mount_target.efs.*.dns_name)}"
}

output "efs_network_interface_id" {
  value = "${join(", ", aws_efs_mount_target.efs.*.network_interface_id)}"
}
