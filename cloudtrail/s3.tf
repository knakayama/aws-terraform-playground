resource "random_id" "bucket_name" {
  byte_length = 8

  keepers = {
    name = "${var.name}"
  }
}

resource "template_file" "bucket_policy" {
  template = "${file("${path.module}/policies/bucket_policy.json.tpl")}"

  vars {
    bucket_name = "${random_id.bucket_name.hex}"
  }
}

resource "aws_s3_bucket" "foo" {
  bucket        = "${random_id.bucket_name.hex}"
  policy        = "${template_file.bucket_policy.rendered}"
  force_destroy = true
}
