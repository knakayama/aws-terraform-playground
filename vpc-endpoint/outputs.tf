output "vpc_endpoint_id" {
  value = "${aws_vpc_endpoint.vpc.id}"
}

output "public_ip" {
  value = "${aws_instance.public.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.private.private_ip}"
}
