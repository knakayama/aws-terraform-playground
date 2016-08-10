resource "aws_elb" "elb" {
  name                        = "${var.name}-elb"
  subnets                     = ["${aws_subnet.public.*.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  idle_timeout                = 60

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/ping"
    interval            = 30
  }

  tags {
    Name = "${var.name}-elb"
  }
}
