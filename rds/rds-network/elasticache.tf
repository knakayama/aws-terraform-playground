resource "aws_elasticache_subnet_group" "redis" {
  name        = "${replace(var.name, "_", "-")}"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
  description = "${replace(var.name, "_", " ")}"
}

resource "aws_elasticache_parameter_group" "default" {
  name   = "${var.name}"
  family = "redis2.8"
}
