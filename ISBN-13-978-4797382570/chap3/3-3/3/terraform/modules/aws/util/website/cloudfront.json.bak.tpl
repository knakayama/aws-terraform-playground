{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "StaticBucket": {
      "Type": "AWS::S3::Bucket",
      "Properties": {
        "BucketName": "chap3-3-1-mystaticsite-aws",
        "WebsiteConfiguration": {
          "IndexDocument": "index.html",
          "ErrorDocument": "error.html",
          "RoutingRules": [
            {
              "RedirectRule": {
                "ReplaceKeyPrefixWith": "foo/"
              },
              "RoutingRuleCondition": {
                "KeyPrefixEquals": "bar/"
              }
            }
          ]
        }
      }
    },
    "StaticBucketPolicy": {
      "Type": "AWS::S3::BucketPolicy",
      "Properties": {
        "Bucket": {
          "Ref": "StaticBucket"
        },
        "PolicyDocument": {
          "Statement": [
            {
              "Effect": "Allow",
              "Principal": {
                "AWS": "*"
              },
              "Action": [
                "s3:GetObject"
              ],
              "Resource": {
                "Fn::Join": ["", ["arn:aws:s3:::", {"Ref": "StaticBucket"}, "/*"]]
              }
            }
          ]
        }
      }
    }
  }
}
