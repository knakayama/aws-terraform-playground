resource "aws_db_parameter_group" "rds" {
  name        = "${var.name}-pg"
  family      = "mysql5.7"
  description = "RDS Parameter Group"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}-subnet-group"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
  description = "RDS Subnet Group"
}

resource "aws_db_instance" "rds" {
  identifier                 = "${var.name}-rds"
  name                       = "rds"
  engine                     = "${var.db_config["engine"]}"
  engine_version             = "${var.db_config["engine_version"]}"
  instance_class             = "${var.db_config["instance_class"]}"
  allocated_storage          = "8"
  storage_type               = "gp2"
  multi_az                   = false
  username                   = "${var.db_config["username"]}"
  password                   = "${var.db_config["password"]}"
  backup_retention_period    = 1
  backup_window              = "04:30-05:00"
  auto_minor_version_upgrade = true
  vpc_security_group_ids     = ["${aws_security_group.rds.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.rds.name}"
  parameter_group_name       = "${aws_db_parameter_group.rds.id}"
  maintenance_window         = "Tue:04:00-Tue:04:30"
  publicly_accessible        = false
}
