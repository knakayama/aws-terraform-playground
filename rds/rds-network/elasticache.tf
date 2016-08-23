resource "aws_elasticache_subnet_group" "redis" {
  name        = "${replace(var.name, "_", "-")}"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
  description = "${replace(var.name, "_", " ")}"
}
