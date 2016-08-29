output "web_public_ips" {
  value = "${join(", ", aws_instance.web.*.public_ip)}"
}

output "web_private_ips" {
  value = "${join(", ", aws_instance.web.*.private_ip)}"
}
