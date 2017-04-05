data "aws_acm_certificate" "acm" {
  domain   = "${var.acm_domain}"
  statuses = ["ISSUED"]
}

data "aws_subnet" "ghe_primary" {
  id = "${var.subnet_ids["ghe_primary"]}"
}

data "aws_subnet" "ghe_secondary" {
  id = "${var.subnet_ids["ghe_secondary"]}"
}

data "aws_instance" "ghe" {
  filter {
    name   = "tag:Name"
    values = ["ghe-01"]
  }
}

resource "aws_elb" "elb" {
  name                        = "${var.name}-elb"
  security_groups             = ["${aws_security_group.elb.id}"]
  instances                   = ["${data.aws_instance.ghe.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  subnets = [
    "${data.aws_subnet.ghe_primary.id}",
    "${data.aws_subnet.ghe_secondary.id}",
  ]

  listener {
    lb_port           = 22
    lb_protocol       = "tcp"
    instance_port     = 22
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 443
    instance_protocol  = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.acm.arn}"
  }

  listener {
    lb_port           = 8080
    lb_protocol       = "http"
    instance_port     = 8080
    instance_protocol = "http"
  }

  listener {
    lb_port            = 8443
    lb_protocol        = "https"
    instance_port      = 8443
    instance_protocol  = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.acm.arn}"
  }

  listener {
    lb_port           = 9418
    lb_protocol       = "tcp"
    instance_port     = 9418
    instance_protocol = "tcp"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTPS:443/status"
    interval            = 30
  }
}

resource "aws_proxy_protocol_policy" "elb" {
  load_balancer = "${aws_elb.elb.name}"

  instance_ports = [
    23,
    81,
    444,
    8081,
    8444,
    9419,
  ]
}
