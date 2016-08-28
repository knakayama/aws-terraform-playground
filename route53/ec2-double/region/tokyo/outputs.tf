output "web_public_ips" {
  value = "${module.tokyo.public_ips}"
}

output "elb_dns_name" {
  value = "${module.tokyo.elb_dns_name}"
}

output "cf_domain_name" {
  value = "${module.cloudfront.cf_domain_name}"
}
