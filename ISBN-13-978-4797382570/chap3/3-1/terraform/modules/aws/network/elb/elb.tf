variable "name"              { default = "elb" }
variable "vpc_id"            { }
variable "public_subnet_ids" { }
variable "web_instance_ids"  { }

variable "rel_path" {
  default = "../../../modules/aws/network/elb/"
}

resource "aws_iam_server_certificate" "elb" {
  name             = "${var.name}"
  certificate_body = "${file(concat(var.rel_path, "certs/server.crt"))}"
  private_key      = "${file(concat(var.rel_path, "certs/server.key"))}"
}

resource "aws_security_group" "elb" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.name}"
  description = "ELB security group"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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

resource "aws_elb" "elb" {
  name                        = "${var.name}"
  subnets                     = ["${concat(split(",", var.public_subnet_ids))}"]
  instances                   = ["${concat(split(",", var.web_instance_ids))}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  security_groups             = ["${aws_security_group.elb.id}"]

  listener {
    instance_port      = 443
    instance_protocol  = "https"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "${aws_iam_server_certificate.elb.arn}"
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:443/index.html"
    interval            = 30
  }

  tags { Name = "${var.name}" }
}

resource "aws_lb_cookie_stickiness_policy" "elb" {
  name                     = "${var.name}"
  load_balancer            = "${aws_elb.elb.id}"
  lb_port                  = 443
  cookie_expiration_period = 1800
}

output "dns_name" { value = "${aws_elb.elb.dns_name}" }
output "sg_id"    { value = "${aws_security_group.elb.id}" }
