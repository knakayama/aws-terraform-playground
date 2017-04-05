data "aws_vpc" "selected" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb"
  vpc_id      = "${data.aws_vpc.selected.id}"
  description = "${var.name}-elb-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["${data.external.my_ip.result["ip"]}"]
  }

  ingress {
    from_port   = 9418
    to_port     = 9418
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
