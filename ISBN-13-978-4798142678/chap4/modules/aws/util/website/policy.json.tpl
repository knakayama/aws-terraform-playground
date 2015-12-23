{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadForGetBucketObjets",
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject"],
      "Resource": ["arn:aws:s3:::${backet_name}/*"],
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "11.22.33.111/32"
        },
        "StringLike": {
          "aws:Referer": "*.aromanet.co.jp/*"
        }
      }
    }
  ]
}
