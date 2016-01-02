variable "name"                { }
variable "vpc_id"              { }
variable "azs"                 { }
variable "key_name"            { }
variable "public_subnet_ids"   { }
variable "private_subnet_ids"  { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "rds_username"        { }
variable "rds_password"        { }
variable "rds_engine"          { }
variable "rds_engine_ver"      { }
variable "rds_instance_type"   { }
variable "rds_family"          { }
variable "max_size"            { }
variable "min_size"            { }

module "web" {
  source = "./web"

  name              = "${var.name}-web"
  vpc_id            = "${var.vpc_id}"
  azs               = "${var.azs}"
  key_name          = "${var.key_name}"
  public_subnet_ids = "${var.public_subnet_ids}"
  instance_type     = "${var.web_instance_type}"
  instance_ami_id   = "${var.web_instance_ami_id}"
  max_size          = "${var.max_size}"
  min_size          = "${var.min_size}"
}

module "rds" {
  source = "./rds"

  name               = "${var.name}-rds"
  vpc_id             = "${var.vpc_id}"
  web_sg_id          = "${module.web.web_sg_id}"
  private_subnet_ids = "${var.private_subnet_ids}"
  username           = "${var.rds_username}"
  password           = "${var.rds_password}"
  engine             = "${var.rds_engine}"
  engine_ver         = "${var.rds_engine_ver}"
  instance_type      = "${var.rds_instance_type}"
  family             = "${var.rds_family}"
}

output "elb_dns_name"         { value = "${module.web.elb_dns_name}" }
output "elb_zone_id"          { value = "${module.web.elb_zone_id}" }
output "rds_endpoint_master"  { value = "${module.rds.endpoint_master}" }
output "rds_endpoint_replica" { value = "${module.rds.endpoint_replica}" }
