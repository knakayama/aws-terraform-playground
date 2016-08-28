output "web_public_ips" {
  value = "${module.seoul.public_ips}"
}

output "elb_dns_name" {
  value = "${module.seoul.elb_dns_name}"
}
