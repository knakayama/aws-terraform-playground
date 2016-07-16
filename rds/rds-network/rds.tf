resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}"
  description = "${var.name}"
  subnet_ids  = ["${aws_subnet.private.*.id}"]

  tags {
    Name = "${var.name}"
  }
}
