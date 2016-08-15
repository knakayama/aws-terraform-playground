output "cidr_blocks" {
  value = "${data.aws_ip_ranges.ap_northeast_1.cidr_blocks}"
}

output "create_date" {
  value = "${data.aws_ip_ranges.ap_northeast_1.create_date}"
}

output "sync_token" {
  value = "${data.aws_ip_ranges.ap_northeast_1.sync_token}"
}
