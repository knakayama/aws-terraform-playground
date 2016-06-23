output "dynamodb_arn" {
  value = "${aws_dynamodb_table.dynamodb.arn}"
}

output "dynamodb_id" {
  value = "${aws_dynamodb_table.dynamodb.id}"
}

#output "dynamodb_stream_arn" {


#  value = "${aws_dynamodb_table.dynamodb.stream_arn}"


#}

