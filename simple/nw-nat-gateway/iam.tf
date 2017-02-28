data "aws_iam_policy_document" "vpc_endpoint" {
  statement {
    sid     = "VPCEndpointPolicy"
    effect  = "Allow"
    actions = ["*"]

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}
