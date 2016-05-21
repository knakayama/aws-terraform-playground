variable "name" {}

variable "azs" {}

variable "vpc_id" {}

variable "private_subnet_ids_db" {}

variable "web_ap_admin_sg_id" {}

variable "web_ap_public_sg_id" {}

variable "rds_db_name" {}

variable "rds_master_username" {}

variable "rds_master_password" {}

variable "rds_class" {}

variable "elasticache_engine" {}

variable "elasticache_engine_ver" {}

variable "elasticache_type" {}

resource "aws_security_group" "rds" {
  name        = "${var.name}-rds"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-rds"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${concat(split(",",var.web_ap_admin_sg_id), split(",", var.web_ap_public_sg_id))}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-rds"
  }
}

resource "aws_security_group" "elasticache" {
  name        = "${var.name}-elasticache"
  vpc_id      = "${var.vpc_id}"
  description = "${var.name}-elasticache"

  ingress {
    from_port       = 11211
    to_port         = 11211
    protocol        = "tcp"
    security_groups = ["${concat(split(",",var.web_ap_admin_sg_id), split(",", var.web_ap_public_sg_id))}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.name}-elasticache"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}"
  description = "${var.name}"
  subnet_ids  = ["${split(",", var.private_subnet_ids_db)}"]

  tags {
    Name = "${var.name}-rds"
  }
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.name}"
  availability_zones      = ["${split(",", var.azs)}"]
  database_name           = "${replace(var.rds_db_name, "-", "_")}"
  master_username         = "${var.rds_master_username}"
  master_password         = "${var.rds_master_password}"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = ["${aws_security_group.rds.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.rds.name}"
}

resource "aws_rds_cluster_instance" "rds" {
  cluster_identifier   = "${aws_rds_cluster.rds.id}"
  instance_class       = "${var.rds_class}"
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"
}

resource "aws_elasticache_subnet_group" "elasticache" {
  name        = "${var.name}-elasticache"
  description = "${var.name}-elasticache"
  subnet_ids  = ["${split(",", var.private_subnet_ids_db)}"]
}

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id         = "${var.name}"
  engine             = "${var.elasticache_engine}"
  engine_version     = "${var.elasticache_engine_ver}"
  maintenance_window = "sun:05:00-sun:06:00"
  node_type          = "${var.elasticache_type}"
  num_cache_nodes    = 1
  port               = 11211
  subnet_group_name  = "${aws_elasticache_subnet_group.elasticache.name}"
  security_group_ids = ["${aws_security_group.elasticache.id}"]

  tags {
    Name = "${var.name}-elasticache"
  }
}

output "rds_endpoint" {
  value = "${aws_rds_cluster_instance.rds.endpoint}"
}

output "elasticache_endpoint" {
  value = "${replace(aws_elasticache_cluster.elasticache.configuration_endpoint, ":11211", "")}"
}
