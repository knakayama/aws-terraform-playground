resource "aws_security_group" "efs" {
  name        = "${var.env}-efs"
  vpc_id      = "${data.aws_vpc.selected.id}"
  description = "${var.env}-SG"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.selected.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
