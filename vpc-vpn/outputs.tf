output "public_ip_oregon" {
  value = "${aws_instance.web_oregon.public_ip}"
}

output "public_ip_tokyo_web" {
  value = "${aws_instance.web_tokyo.public_ip}"
}

output "public_ip_tokyo_vyos" {
  value = "${aws_instance.vyos_tokyo.public_ip}"
}

output "private_ip_tokyo_vyos" {
  value = "${aws_instance.vyos_tokyo.private_ip}"
}
