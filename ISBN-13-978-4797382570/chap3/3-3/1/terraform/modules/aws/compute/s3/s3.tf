variable "name"        { default = "s3" }
variable "policy_file" { }
variable "acl"         { }
variable "htmls"       { }

variable "rel_path" {
  default = "../../../modules/aws/compute/s3/"
}

# FIXME:
#resource "aws_cloudformation_stack" "s3" {
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

resource "template_file" "s3" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet_name = "${var.name}"
  }
}

resource "aws_s3_bucket" "s3" {
  bucket        = "${var.name}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.s3.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "s3" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.s3.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(var.rel_path, element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

output "website_endpoint" { value = "${aws_s3_bucket.s3.website_endpoint}" }
