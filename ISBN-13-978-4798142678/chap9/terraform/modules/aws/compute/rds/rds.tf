variable "name"               { default = "rds" }
variable "vpc_id"             { }
variable "public_subnet"      { }
variable "private_subnet_ids" { }
variable "rds_username"       { }
variable "rds_password"       { }
variable "rds_engine"         { }
variable "rds_engine_ver"     { }
variable "rds_instance_type"  { }

resource "aws_security_group" "rds" {
  name        = "${var.name}"
  vpc_id      = "${var.vpc_id}"
  description = "RDS security group"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${var.public_subnet}"]
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

resource "aws_db_instance" "rds" {
  identifier                 = "${var.name}"
  name                       = "my_rds"
  allocated_storage          = 5
  engine                     = "${var.rds_engine}"
  engine_version             = "${var.rds_engine_ver}"
  instance_class             = "${var.rds_instance_type}"
  storage_type               = "gp2"
  multi_az                   = true
  username                   = "${var.rds_username}"
  password                   = "${var.rds_password}"
  backup_retention_period    = 1
  auto_minor_version_upgrade = true
  vpc_security_group_ids     = ["${aws_security_group.rds.id}"]
  db_subnet_group_name       = "${aws_db_subnet_group.rds.name}"

  tags { Name = "${var.name}" }
}

output "endpoint"    { value = "${aws_db_instance.rds.endpoint}" }
output "instance_id" { value = "${aws_db_instance.rds.id}" }
