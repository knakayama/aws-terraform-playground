output "web_public_ip" {
  value = "${aws_instance.web.public_ip}"
}

output "s3_arn" {
  value = "${aws_s3_bucket.s3.arn}"
}
