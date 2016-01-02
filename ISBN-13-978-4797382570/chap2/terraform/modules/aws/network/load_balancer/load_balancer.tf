variable "name"              { default = "load_balancer" }
variable "vpc_id"            { }
variable "public_subnet_ids" { }
variable "web_instance_ids"  { }

resource "aws_security_group" "load_balancer" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "ELB security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_elb" "load_balancer" {
  name                        = "${var.name}"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  instances                   = ["${split(",", var.web_instance_ids)}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  security_groups             = ["${aws_security_group.load_balancer.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/index.html"
    interval            = 30
  }

  tags { Name = "${var.name}" }
}

output "dns_name" { value = "${aws_elb.load_balancer.dns_name}" }
