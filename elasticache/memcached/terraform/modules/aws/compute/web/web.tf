variable "name"                { default = "web" }
variable "vpc_id"              { }
variable "azs"                 { }
variable "key_name"            { }
variable "public_subnet_ids"   { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${var.vpc_id}"
  description = "ELB SG"

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

resource "aws_security_group" "web" {
  name        = "${var.name}-web"
  vpc_id      = "${var.vpc_id}"
  description = "Web SG"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  count                       = "${length(split(",", var.azs))}"
  ami                         = "${var.web_instance_ami_id}"
  instance_type               = "${var.web_instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.web.id}"]
  subnet_id                   = "${element(split(",", var.public_subnet_ids), count.index)}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true

  root_block_device = {
    volume_type = "gp2"
    volume_size = 8
  }

  tags { Name = "${var.name}" }
}

resource "aws_iam_server_certificate" "elb" {
  name             = "${var.name}"
  private_key      = "${file(concat(path.module, "/certs/server.key"))}"
  certificate_body = "${file(concat(path.module, "/certs/server.crt"))}"
}

resource "aws_elb" "elb" {
  name                        = "${var.name}"
  subnets                     = ["${split(",", var.public_subnet_ids)}"]
  instances                   = ["${aws_instance.web.*.id}"]
  security_groups             = ["${aws_security_group.elb.id}"]
  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    lb_port            = 443
    lb_protocol        = "https"
    instance_port      = 80
    instance_protocol  = "http"
    ssl_certificate_id = "${aws_iam_server_certificate.elb.arn}"
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

output "elb_dns_name"          { value = "${aws_elb.elb.dns_name}" }
output "elb_zone_id"           { value = "${aws_elb.elb.zone_id}" }
output "web_public_ips"        { value = "${join(",", aws_instance.web.*.public_ip)}" }
output "web_security_group_id" { value = "${aws_security_group.web.id}" }
