variable "name"              { default = "rds" }
variable "vpc_id"            { }
variable "public_subnet_ids" { }
variable "username"          { }
variable "password"          { }
variable "engine"            { }
variable "engine_ver"        { }
variable "instance_type"     { }
variable "family"            { }

resource "aws_security_group" "rds" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "RDS security group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags { Name = "${var.name}" }
}

resource "aws_db_parameter_group" "rds" {
  name        = "${var.name}"
  family      = "${var.family}"
  description = "RDS parameter group"

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
  name        = "${var.name}"
  subnet_ids  = ["${split(",", var.public_subnet_ids)}"]
  description = "RDS subnet group"

  tags { Name = "${var.name}" }
}

resource "aws_db_instance" "rds" {
  identifier                 = "${var.name}"
  name                       = "my_rds"
  allocated_storage          = 5
  engine                     = "${var.engine}"
  engine_version             = "${var.engine_ver}"
  instance_class             = "${var.instance_type}"
  storage_type               = "gp2"
  multi_az                   = true
  username                   = "${var.username}"
  password                   = "${var.password}"
  backup_retention_period    = 1
  backup_window              = "04:30-05:00"
  auto_minor_version_upgrade = true
  vpc_security_group_ids     = ["${aws_security_group.rds.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.rds.name}"
  parameter_group_name       = "${aws_db_parameter_group.rds.id}"
  maintenance_window         = "Tue:04:00-Tue:04:30"
  publicly_accessible        = true

  tags { Name = "${var.name}" }
}

output "endpoint" { value = "${aws_db_instance.rds.endpoint}" }
