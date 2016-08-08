variable "name"                   { }
variable "vpc_id"                 { }
variable "azs"                    { }
variable "key_name"               { }
variable "public_subnets"         { }
variable "public_subnet_ids"      { }
variable "private_subnet_ids"     { }
variable "web_instance_type"      { }
variable "web_instance_ami_id"    { }
variable "rds_username"           { }
variable "rds_password"           { }
variable "rds_engine"             { }
variable "rds_engine_ver"         { }
variable "rds_instance_type"      { }
variable "elasticache_engine"     { }
variable "elasticache_engine_ver" { }
variable "elasticache_node_type"  { }

module "rds" {
  source = "./rds"

  name               = "${var.name}-rds"
  vpc_id             = "${var.vpc_id}"
  public_subnets     = "${var.public_subnets}"
  private_subnet_ids = "${var.private_subnet_ids}"
  rds_username       = "${var.rds_username}"
  rds_password       = "${var.rds_password}"
  rds_engine         = "${var.rds_engine}"
  rds_engine_ver     = "${var.rds_engine_ver}"
  rds_instance_type  = "${var.rds_instance_type}"
}

module "web" {
  source = "./web"

  name                = "${var.name}-web"
  vpc_id              = "${var.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${var.key_name}"
  public_subnet_ids   = "${var.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

module "elasticache" {
  source = "./elasticache"

  name                  = "${var.name}-elasticache"
  vpc_id                = "${var.vpc_id}"
  web_security_group_id = "${module.web.web_security_group_id}"
  rds_security_group_id = "${module.rds.security_group_id}"
  private_subnet_ids    = "${var.private_subnet_ids}"
  engine                = "${var.elasticache_engine}"
  engine_ver            = "${var.elasticache_engine_ver}"
  node_type             = "${var.elasticache_node_type}"
}

output "web_public_ips" { value = "${module.web.web_public_ips}" }
output "elb_dns_name"   { value = "${module.web.elb_dns_name}" }
output "elb_zone_id"    { value = "${module.web.elb_zone_id}" }
output "rds_endpoint"   { value = "${module.rds.endpoint}" }
