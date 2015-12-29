variable "name"              { }
variable "vpc_id"            { }
variable "public_subnet_ids" { }
variable "rds_username"      { }
variable "rds_password"      { }
variable "rds_engine"        { }
variable "rds_engine_ver"    { }
variable "rds_instance_type" { }
variable "rds_family"        { }

module "rds" {
  source = "./rds"

  name              = "${var.name}-rds"
  vpc_id            = "${var.vpc_id}"
  public_subnet_ids = "${var.public_subnet_ids}"
  username          = "${var.rds_username}"
  password          = "${var.rds_password}"
  engine            = "${var.rds_engine}"
  engine_ver        = "${var.rds_engine_ver}"
  instance_type     = "${var.rds_instance_type}"
  family            = "${var.rds_family}"
}

output "rds_endpoint"    { value = "${module.rds.endpoint}" }
