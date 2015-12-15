provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_iam_group" "chap3-3-1-iam-group" {
  name = "chap3-3-1-my-iam-group"
  path = "/"
}

resource "aws_iam_group_policy" "chap3-3-1-iam-group-policy" {
  name = "${aws_iam_group.chap3-3-1-iam-group.name}"
  group = "${aws_iam_group.chap3-3-1-iam-group.id}"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOT
}

resource "aws_iam_user" "chap3-3-1-iam-user" {
  name = "chap3-3-1-iam-user"
}

resource "aws_iam_group_membership" "chap3-3-1-iam-membership" {
  name = "chap3-3-1-iam-membership"
  users = [
    "${aws_iam_user.chap3-3-1-iam-user.name}"
  ]
  group = "${aws_iam_group.chap3-3-1-iam-group.name}"
}

# FIXME:
#resource "aws_cloudformation_stack" "chap3-3-1-redirect-rule" {
#  name = "chap3-3-1-redirect-stack"
#  template_body = <<STACK
#{
#  "AWSTemplateFormatVersion": "2010-09-09",
#  "Resources": {
#    "StaticBucket": {
#      "Type": "AWS::S3::Bucket",
#      "Properties": {
#        "BucketName": "chap3-3-1-mystaticsite-aws",
#        "WebsiteConfiguration": {
#          "IndexDocument": "index.html",
#          "ErrorDocument": "error.html",
#          "RoutingRules": [
#            {
#              "RedirectRule": {
#                "ReplaceKeyPrefixWith": "foo/"
#              },
#              "RoutingRuleCondition": {
#                "KeyPrefixEquals": "bar/"
#              }
#            }
#          ]
#        }
#      }
#    },
#    "StaticBucketPolicy": {
#      "Type": "AWS::S3::BucketPolicy",
#      "Properties": {
#        "Bucket": {
#          "Ref": "StaticBucket"
#        },
#        "PolicyDocument": {
#          "Statement": [
#            {
#              "Effect": "Allow",
#              "Principal": {
#                "AWS": "*"
#              },
#              "Action": [
#                "s3:GetObject"
#              ],
#              "Resource": {
#                "Fn::Join": ["", ["arn:aws:s3:::", {"Ref": "StaticBucket"}, "/*"]]
#              }
#            }
#          ]
#        }
#      }
#    }
#  }
#}
#STACK
#}

resource "aws_s3_bucket" "chap3-3-1-s3-bucket" {
  bucket = "chap3-3-1-mystaticsite-aws"
  acl = "public-read"
  policy = "${file("policy.json")}"
  force_destroy = true
  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# FIXME: Is there more better coding style?
resource "aws_s3_bucket_object" "chap3-3-1-s3-bucket-object-index" {
  bucket = "${aws_s3_bucket.chap3-3-1-s3-bucket.bucket}"
  key = "index.html"
  source = "index.html"
  content_type = "text/html"
}
resource "aws_s3_bucket_object" "chap3-3-1-s3-bucket-object-error" {
  bucket = "${aws_s3_bucket.chap3-3-1-s3-bucket.bucket}"
  key = "error.html"
  source = "error.html"
  content_type = "text/html"
}

output "s3 endpoint" {
  value = "${aws_s3_bucket.chap3-3-1-s3-bucket.website_endpoint}"
}
