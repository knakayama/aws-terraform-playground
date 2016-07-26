output "api_gateway_rest_api_id" {
  value = "${aws_api_gateway_rest_api.api.id}"
}

output "api_gateway_rest_api_root_resource_id" {
  value = "${aws_api_gateway_rest_api.api.root_resource_id}"
}

output "aws_api_gateway_resource_id" {
  value = "${aws_api_gateway_resource.api.id}"
}

output "aws_api_gateway_resource_path" {
  value = "${aws_api_gateway_resource.api.path}"
}
