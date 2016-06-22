resource "aws_security_group" "public" {
  name_prefix = "${var.name}-web-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} web SG"

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_security_group" "private" {
  name_prefix = "${var.name}-web-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} web SG"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.public.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
