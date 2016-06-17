variable "s3_bucket_name" {
  default = "s3_bucket_name"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "random_id" "random_s3_bucket_name" {
  keepers = {
    random_s3_bucket_name = "${var.s3_bucket_name}"
  }

  byte_length = 8
}

data "aws_iam_policy_document" "example" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${random_id.random_s3_bucket_name.hex}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${random_id.random_s3_bucket_name.hex}/home/&{aws:username}",
      "arn:aws:s3:::${random_id.random_s3_bucket_name.hex}/home/&{aws:username}/*",
    ]
  }
}

resource "aws_iam_policy" "example" {
  name   = "example_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.example.json}"
}
