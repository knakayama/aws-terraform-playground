output "web_public_ip" {
  value = "${module.main.web_public_ip}"
}

output "s3_arn" {
  value = "${module.main.s3_arn}"
}
