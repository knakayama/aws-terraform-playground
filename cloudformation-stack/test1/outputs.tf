output "cfn_output_arn" {
  value = "${aws_cloudformation_stack.vpc.outputs.ARN}"
}

output "cfn_output_cidrblock" {
  value = "${aws_cloudformation_stack.vpc.outputs.CidrBlock}"
}
