variable "policy_file"     { }
variable "acl"             { }
variable "htmls"           { }
variable "domain"          { }
variable "sub_domain_s3"   { }
variable "sub_domain_data" { }

resource "template_file" "website_s3" {
  template = "${file(concat(path.module, "/", var.policy_file))}"

  vars {
    backet = "${var.sub_domain_s3}.${var.domain}"
  }
}

resource "template_file" "website_data" {
  template = "${file(concat(path.module, "/", var.policy_file))}"

  vars {
    backet = "${var.sub_domain_data}.${var.domain}"
  }
}

resource "aws_s3_bucket" "website_s3" {
  bucket = "${var.sub_domain_s3}.${var.domain}"
  acl    = "${var.acl}"
  policy = "${template_file.website_s3.rendered}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket" "website_data" {
  bucket = "${var.sub_domain_data}.${var.domain}"
  acl    = "${var.acl}"
  policy = "${template_file.website_data.rendered}"
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "website" {
  count  = "${length(split(",", var.htmls))}"
  bucket = "${aws_s3_bucket.website_s3.bucket}"
  key    = "${element(split(",", var.htmls), count.index)}"
  source = "${concat(path.module, "/", element(split(",", var.htmls), count.index))}"
  content_type = "text/html"
}

output "website_endpoint_s3"   { value = "${aws_s3_bucket.website_s3.website_endpoint}" }
output "website_endpoint_data" { value = "${aws_s3_bucket.website_data.website_endpoint}" }
