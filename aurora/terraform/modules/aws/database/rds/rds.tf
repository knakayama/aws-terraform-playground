variable "name"                  { default = "rds" }
variable "vpc_id"                { }
variable "azs"                   { }
variable "web_security_group_id" { }
variable "private_subnet_ids"    { }
variable "database_name"         { }
variable "master_username"       { }
variable "master_password"       { }
variable "instance_class"        { }

resource "aws_security_group" "rds" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "RDS security group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${var.web_security_group_id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_db_subnet_group" "rds" {
  name        = "${var.name}"
  subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
  description = "RDS db subnet group"

  tags { Name = "${var.name}" }
}

resource "aws_rds_cluster" "rds" {
  cluster_identifier      = "${var.name}"
  availability_zones      = ["${split(",", var.azs)}"]
  database_name           = "${var.database_name}"
  master_username         = "${var.master_username}"
  master_password         = "${var.master_password}"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = ["${aws_security_group.rds.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.rds.name}"
}

resource "aws_rds_cluster_instance" "rds" {
  count                = "${length(split(",", var.azs))}"
  #identifier           = "${var.name}"
  cluster_identifier   = "${aws_rds_cluster.rds.id}"
  instance_class       = "${var.instance_class}"
  db_subnet_group_name = "${aws_db_subnet_group.rds.name}"
}

output "endpoints" { value = "${join(",", aws_rds_cluster_instance.rds.*.endpoint)}" }
