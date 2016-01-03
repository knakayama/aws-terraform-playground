variable "name"        { default = "website" }
variable "policy_file" { }
variable "acl"         { }
variable "htmls"       { }

# FIXME:
#resource "aws_cloudformation_stack" "website" {
#  name          = "${var.name}"
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

resource "template_file" "website" {
  template = "${file(concat(path.module, "/", var.policy_file))}"

  vars {
    backet_name = "${var.name}"
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = "${var.name}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.website.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(path.module, "/", element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

output "endpoint"       { value = "${aws_s3_bucket.website.website_endpoint}" }
output "domain"         { value = "${aws_s3_bucket.website.website_domain}" }
output "hosted_zone_id" { value = "${aws_s3_bucket.website.hosted_zone_id}" }
