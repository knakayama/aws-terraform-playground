output "public_ip" {
  value = "${module.main.public_ip}"
}

output "spot_bid_status" {
  value = "${module.main.spot_bid_status}"
}

output "spot_request_state" {
  value = "${module.main.spot_request_state}"
}

output "spot_instance_id" {
  value = "${module.main.spot_instance_id}"
}
