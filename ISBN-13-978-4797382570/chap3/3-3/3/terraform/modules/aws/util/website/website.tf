variable "name"        { default = "website" }
variable "policy_file" { }
variable "acl"         { }
variable "htmls"       { }
variable "domain"      { }
variable "sub_domain"  { }

variable "rel_path" {
  default = "../../../modules/aws/util/website/"
}

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

resource "template_file" "website_policy" {
  template = "${file(concat(var.rel_path, var.policy_file))}"

  vars {
    backet_name = "${var.name}"
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = "${var.name}"
  acl           = "${var.acl}"
  force_destroy = true
  policy        = "${template_file.website_policy.rendered}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website" {
  count        = "${length(split(",", var.htmls))}"
  bucket       = "${aws_s3_bucket.website.bucket}"
  key          = "${element(split(",", var.htmls), count.index)}"
  source       = "${concat(var.rel_path, element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

resource "aws_route53_zone" "website" {
  name = "${var.domain}"
}

resource "aws_route53_record" "website" {
  zone_id = "${aws_route53_zone.website.zone_id}"
  name    = "${var.sub_domain}.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_s3_bucket.website.website_endpoint}"]
}

resource "template_file" "website_cloudfront" {
  template = "${file(concat(var.rel_path, "cloudfront.json.tpl"))}"

  vars {
    id               = "${var.name}"
    domain_name      = "${var.sub_domain}.${var.domain}"
    website_endpoint = "${aws_s3_bucket.website.website_endpoint}"
  }
}

resource "aws_cloudformation_stack" "website" {
  name          = "${var.name}"
  template_body = "${template_file.website_cloudfront.rendered}"
}

output "s3_website_endpoint" { value = "${aws_s3_bucket.website.website_endpoint}" }
output "route53_record_fqdn" { value = "${aws_route53_record.website.fqdn}" }
