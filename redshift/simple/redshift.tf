resource "aws_redshift_parameter_group" "pg" {
  name        = "${var.name}"
  family      = "redshift-1.0"
  description = "${replace(var.name, "-", " ")}"

  parameter {
    name  = "require_ssl"
    value = "true"
  }

  parameter {
    name  = "enable_user_activity_logging"
    value = "true"
  }
}

resource "aws_redshift_subnet_group" "sg" {
  name        = "${var.name}"
  description = "${replace(var.name, "-", " ")}"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
}

resource "aws_redshift_cluster" "cluster" {
  cluster_identifier                  = "${var.name}"
  database_name                       = "mydwh"
  master_username                     = "root"
  master_password                     = "pAssw0rd"
  node_type                           = "dc1.large"
  cluster_type                        = "multi-node"
  vpc_security_group_ids              = ["${aws_security_group.redshift.id}"]
  cluster_subnet_group_name           = "${aws_redshift_subnet_group.sg.id}"
  preferred_maintenance_window        = "sat:20:00-sat:20:30"
  cluster_parameter_group_name        = "${aws_redshift_parameter_group.pg.id}"
  automated_snapshot_retention_period = 7
  number_of_nodes                     = 3
  publicly_accessible                 = false
  skip_final_snapshot                 = true
}
