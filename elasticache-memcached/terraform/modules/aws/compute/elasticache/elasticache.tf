variable "name"                  { default = "elasticache" }
variable "vpc_id"                { }
variable "web_security_group_id" { }
variable "rds_security_group_id" { }
variable "private_subnet_ids"    { }
variable "engine"                { }
variable "engine_ver"            { }
variable "node_type"             { }

resource "aws_security_group" "memcached" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.name}"
  description = "ElastiCache SG"

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = ["${var.web_security_group_id}"]
  }

  egress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = ["${var.rds_security_group_id}"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_elasticache_subnet_group" "memcached" {
  name        = "${var.name}"
  subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
  description = "ElastiCache subnet group"
}

resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "${var.name}"
  engine               = "${var.engine}"
  engine_version       = "${var.engine_ver}"
  maintenance_window   = "sun:05:00-sun:06:00"
  node_type            = "${var.node_type}"
  num_cache_nodes      = 1
  port                 = 11211
  subnet_group_name    = "${aws_elasticache_subnet_group.memcached.name}"
  security_group_ids   = ["${aws_security_group.memcached.id}"]

  tags { Name = "${var.name}" }
}

#resource "aws_cloudwatch_metric_alarm" "cpu" {
#  alarm_name          = "alarmCacheClusterCPUUtilization-${var.cache_name}"
#  alarm_description   = "Cache cluster CPU utilization"
#  comparison_operator = "GreaterThanThreshold"
#  evaluation_periods  = "1"
#  metric_name         = "CPUUtilization"
#  namespace           = "AWS/ElastiCache"
#  period              = "300"
#  statistic           = "Average"
#  threshold           = "75"
#
#  dimensions {
#    CacheClusterId = "${aws_elasticache_cluster.memcached.id}"
#  }
#
#  alarm_actions = ["${split(",", var.alarm_actions)}"]
#}
#
#resource "aws_cloudwatch_metric_alarm" "memory_free" {
#  alarm_name          = "alarmCacheClusterFreeableMemory-${var.cache_name}"
#  alarm_description   = "Cache cluster freeable memory"
#  comparison_operator = "LessThanThreshold"
#  evaluation_periods  = "1"
#  metric_name         = "FreeableMemory"
#  namespace           = "AWS/ElastiCache"
#  period              = "60"
#  statistic           = "Average"
#
#  # 10MB in bytes
#  threshold = "10000000"
#
#  dimensions {
#    CacheClusterId = "${aws_elasticache_cluster.memcached.id}"
#  }
#
#  alarm_actions = ["${split(",", var.alarm_actions)}"]
#}
