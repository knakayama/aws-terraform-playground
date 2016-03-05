variable "name"                  { }
variable "vpc_id"                { }
variable "azs"                   { }
variable "web_security_group_id" { }
variable "private_subnet_ids"    { }
variable "rds_database_name"     { }
variable "rds_master_username"   { }
variable "rds_master_password"   { }
variable "rds_instance_class"    { }

module "rds" {
  source = "./rds"

  name                  = "${var.name}-rds"
  azs                   = "${var.azs}"
  vpc_id                = "${var.vpc_id}"
  web_security_group_id = "${var.web_security_group_id}"
  private_subnet_ids    = "${var.private_subnet_ids}"
  database_name         = "${var.rds_database_name}"
  master_username       = "${var.rds_master_username}"
  master_password       = "${var.rds_master_password}"
  instance_class        = "${var.rds_instance_class}"
}

output "rds_endpoints" { value = "${module.rds.endpoints}" }
