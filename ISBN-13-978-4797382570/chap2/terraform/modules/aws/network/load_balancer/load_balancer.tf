variable "name"              { default = "load_balancer" }
variable "vpc_id"            { }
variable "public_subnet_ids" { }
variable "web_instance_ids"  { }

resource "aws_security_group" "load_balancer" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "ELB security group"

  tags { Name = "${var.name}" }

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
}

resource "aws_elb" "load_balancer" {
  name                        = "${var.name}"
  subnets                     = ["${concat(split(",", var.public_subnet_ids))}"]
  instances                   = ["${concat(split(",", var.web_instance_ids))}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300
  security_groups             = ["${concat(split(",", aws_security_group.load_balancer.id))}"]
  # * aws_elb.chap2-elb: ValidationError: Only one of SubnetIds or AvailabilityZones may be specified
  #availability_zones = [
  #  "${aws_instance.chap2-instance-a.availability_zone}",
  #  "${aws_instance.chap2-instance-c.availability_zone}"
  #]

  tags { Name = "${var.name}" }

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
}

output "dns_name" { value = "${aws_elb.load_balancer.dns_name}" }
