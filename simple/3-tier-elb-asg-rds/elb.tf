resource "aws_elb" "elb" {
  subnets                     = ["${aws_subnet.frontend_subnet.*.id}"]
  idle_timeout                = 60
  security_groups             = ["${aws_security_group.elb.id}"]
  connection_draining         = true
  connection_draining_timeout = 300
  cross_zone_load_balancing   = true

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
    healthy_threshold   = 10
    unhealthy_threshold = 2
  }

  access_logs {
    bucket        = "${aws_s3_bucket.elb_log.bucket}"
    bucket_prefix = "demo"
    interval      = 60
  }
}
