data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.domain_config["s3_sub_domain"]}.${var.domain_config["domain"]}/*"]
    effect    = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.cf.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "s3" {
  bucket = "${var.domain_config["s3_sub_domain"]}.${var.domain_config["domain"]}"
  policy = "${data.aws_iam_policy_document.s3_policy.json}"
}
