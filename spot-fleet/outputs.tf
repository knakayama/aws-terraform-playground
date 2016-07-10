output "spot_fleet_id" {
  value = "${aws_spot_fleet_request.fleet.id}"
}

output "spot_fleet_request_state" {
  value = "${aws_spot_fleet_request.fleet.spot_request_state}"
}
