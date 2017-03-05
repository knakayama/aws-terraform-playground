data "aws_iam_policy_document" "s3" {
  statement {
    sid       = "PublicRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::test.${var.acm_config["domain"]}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "s3" {
  bucket        = "test.${var.acm_config["domain"]}"
  acl           = "public-read"
  policy        = "${data.aws_iam_policy_document.s3.json}"
  force_destroy = true

  website = {
    index_document = "index.html"
  }
}
