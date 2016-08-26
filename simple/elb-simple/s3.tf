data "aws_elb_service_account" "elb_log" {}

data "aws_iam_policy_document" "elb_log" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::${var.name}-elb-log/*",
    ]

    principals = {
      type = "AWS"

      identifiers = [
        "${data.aws_elb_service_account.elb_log.id}",
      ]
    }
  }
}

resource "aws_s3_bucket" "elb_log" {
  bucket        = "${var.name}-elb-log"
  acl           = "private"
  policy        = "${data.aws_iam_policy_document.elb_log.json}"
  force_destroy = true
}
