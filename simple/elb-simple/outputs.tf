output "web_public_ip" {
  value = "${join(", ", aws_spot_instance_request.web.*.public_ip)}"
}

output "elb_dns_name" {
  value = "${aws_elb.elb.dns_name}"
}

output "spot_bid_status" {
  value = "${join(", ", aws_spot_instance_request.web.spot_bid_status)}"
}

output "spot_request_state" {
  value = "${join(", ", aws_spot_instance_request.web.spot_request_state)}"
}

output "spot_instance_id" {
  value = "${join(", ", aws_spot_instance_request.web.spot_instance_id)}"
}
