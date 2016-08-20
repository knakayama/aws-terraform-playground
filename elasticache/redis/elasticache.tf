resource "aws_elasticache_subnet_group" "redis" {
  name        = "${replace(var.name, "_", "-")}"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
  description = "${replace(var.name, "_", " ")}"
}

resource "aws_elasticache_parameter_group" "redis" {
  name        = "${replace(var.name, "_", "-")}"
  family      = "redis2.8"
  description = "${replace(var.name, "_", " ")}"
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${element(split("_", var.name), 0)}"
  engine               = "${var.redis_config["engine"]}"
  engine_version       = "${var.redis_config["engine_version"]}"
  maintenance_window   = "sun:05:00-sun:06:00"
  node_type            = "${var.redis_config["node_type"]}"
  num_cache_nodes      = 1
  parameter_group_name = "${aws_elasticache_parameter_group.redis.id}"
  port                 = 6379
  subnet_group_name    = "${aws_elasticache_subnet_group.redis.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]

  tags {
    Name = "${var.name}-redis"
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = "${replace(var.name, "_", "-")}-rep"
  replication_group_description = "${replace(var.name, "_", " ")}"
  node_type                     = "${var.redis_config["replication_node_type"]}"
  engine_version                = "${var.redis_config["engine_version"]}"
  number_cache_clusters         = 2
  port                          = 6379
  parameter_group_name          = "${aws_elasticache_parameter_group.redis.id}"
  subnet_group_name             = "${aws_elasticache_subnet_group.redis.name}"
  security_group_ids            = ["${aws_security_group.redis.id}"]
  automatic_failover_enabled    = true
  maintenance_window            = "sun:05:00-sun:06:00"
}
