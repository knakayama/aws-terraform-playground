resource "aws_alb_target_group" "alb" {
  name     = "${var.name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    interval            = 30
    path                = "/index.html"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
}

resource "aws_alb" "alb" {
  name                       = "${var.name}"
  security_groups            = ["${aws_security_group.alb.id}"]
  subnets                    = ["${aws_subnet.frontend_subnet.*.id}"]
  internal                   = false
  enable_deletion_protection = false

  #access_logs {


  #  bucket = "${aws_s3_bucket.alb_logs.bucket}"


  #  prefix = "test-alb"


  #}

  tags {
    Environment = "${var.name}-alb"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = "${data.aws_acm_certificate.acm.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb.arn}"
    type             = "forward"
  }
}
