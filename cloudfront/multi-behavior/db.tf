resource "aws_db_subnet_group" "db" {
  name        = "${var.name}-aurora"
  description = "${var.name} aurora"
  subnet_ids  = ["${aws_subnet.datastore_subnet.*.id}"]

  tags {
    Name = "${var.name}-aurora"
  }
}

resource "aws_db_parameter_group" "db" {
  name        = "${var.name}-aurora"
  family      = "${var.db_config["family"]}"
  description = "${var.name} aurora"
}

resource "aws_rds_cluster" "db" {
  cluster_identifier      = "${var.name}-aurora"
  availability_zones      = ["${var.azs}"]
  database_name           = "${var.db_config["db_name"]}"
  master_username         = "${var.db_config["username"]}"
  master_password         = "${var.db_config["password"]}"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = ["${aws_security_group.db.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.db.name}"
}

resource "aws_rds_cluster_instance" "db" {
  cluster_identifier      = "${var.name}-aurora"
  instance_class          = "${var.db_config["instance_class"]}"
  db_subnet_group_name    = "${aws_db_subnet_group.db.name}"
  db_parameter_group_name = "${aws_db_parameter_group.db.id}"

  tags {
    Name = "${var.name}-aurora"
  }
}
