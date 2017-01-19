output "public_ips" {
  value = "${join(" ", aws_spot_instance_request.web.*.public_ip)}"
}
