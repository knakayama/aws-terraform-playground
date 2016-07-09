resource "aws_security_group" "compute" {
  name        = "${var.name}-bastion-ssh"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} bastion ssh"

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

  tags {
    Name = "${var.name}"
  }
}
