resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} bastion sg"

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
    Name = "${var.name}-bastion-sg"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.name}-elb-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} elb sg"

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

  tags {
    Name = "${var.name}-elb-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} app sg"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.name}-db-sg"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} db sg"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-db-sg"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "${var.name} redis"

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-redis"
  }
}
