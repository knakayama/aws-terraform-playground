resource "aws_db_subnet_group" "rds1" {
  name        = "${var.name}-rds1"
  description = "${var.name}"
  subnet_ids  = ["${aws_subnet.private1.*.id}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_db_subnet_group" "rds2" {
  name        = "${var.name}-rds2"
  description = "${var.name}"
  subnet_ids  = ["${aws_subnet.private2.*.id}"]

  tags {
    Name = "${var.name}"
  }
}

resource "aws_db_parameter_group" "rds" {
  name   = "${var.name}"
  family = "postgres9.5"
}
