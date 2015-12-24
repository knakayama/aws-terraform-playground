variable "name"                { }
variable "vpc_id"              { }
variable "public_subnet"       { }
variable "public_subnet_id"    { }
variable "private_subnet_ids"  { }
variable "key_name"            { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "rds_username"        { }
variable "rds_password"        { }
variable "rds_engine"          { }
variable "rds_engine_ver"      { }
variable "rds_instance_type"   { }

module "web" {
  source = "./web"

  name             = "${var.name}-web"
  vpc_id           = "${var.vpc_id}"
  public_subnet_id = "${var.public_subnet_id}"
  key_name         = "${var.key_name}"
  instance_type    = "${var.web_instance_type}"
  instance_ami_id  = "${var.web_instance_ami_id}"
}

module "rds" {
  source = "./rds"

  name               = "${var.name}-rds"
  vpc_id             = "${var.vpc_id}"
  public_subnet      = "${var.public_subnet}"
  private_subnet_ids = "${var.private_subnet_ids}"
  rds_username       = "${var.rds_username}"
  rds_password       = "${var.rds_password}"
  rds_engine         = "${var.rds_engine}"
  rds_engine_ver     = "${var.rds_engine_ver}"
  rds_instance_type  = "${var.rds_instance_type}"
}

output "web_public_ip"   { value = "${module.web.public_ip}" }
output "web_instance_id" { value = "${module.web.instance_id}" }
output "rds_endpoint"    { value = "${module.rds.endpoint}" }
output "rds_instance_id" { value = "${module.rds.instance_id}" }
