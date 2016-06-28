output "web_public_ips" {
  value = "${join(", ", aws_instance.web.*.public_ip)}"
}
