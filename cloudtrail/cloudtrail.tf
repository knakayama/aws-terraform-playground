resource "aws_cloudtrail" "foobar" {
  name                          = "${var.name}"
  s3_bucket_name                = "${aws_s3_bucket.foo.id}"
  s3_key_prefix                 = "/prefix"
  include_global_service_events = false
}
