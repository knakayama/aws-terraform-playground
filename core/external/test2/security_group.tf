resource "aws_security_group" "sg" {
  name_prefix = "test"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "test"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
