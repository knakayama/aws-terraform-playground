resource "aws_cloudfront_origin_access_identity" "cf" {
  comment = "${var.name}-cf"
}

resource "aws_cloudfront_distribution" "cf" {
  comment          = "${var.name}-cf"
  price_class      = "${var.cf_config["price_class"]}"
  aliases          = ["${var.domain_config["cf_sub_domain"]}.${var.domain_config["domain"]}"]
  retain_on_delete = true
  enabled          = true

  origin {
    domain_name = "${var.domain_config["elb_sub_domain"]}.${var.domain_config["domain"]}"
    origin_id   = "ELB-${aws_elb.elb.name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
  }

  origin {
    domain_name = "${aws_s3_bucket.s3.id}.s3.amazonaws.com"
    origin_id   = "S3-${aws_s3_bucket.s3.id}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.cf.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ELB-${aws_elb.elb.name}"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  cache_behavior {
    path_pattern           = "img/*.jpg"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.s3.id}"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
