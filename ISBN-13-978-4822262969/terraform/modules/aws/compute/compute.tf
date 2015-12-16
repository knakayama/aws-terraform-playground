variable "name"                  { default = "mysql" }
variable "vpc_id"                { }
variable "vpc_cidr"              { }
variable "public_subnets"        { }
variable "private_subnet_ids"    { }
variable "key_name"              { }
variable "mysql_instance_type"   { }
variable "mysql_instance_ami_id" { }
variable "bastion_public_ip"     { }
variable "bastion_user"          { }

module "mysql" {
  source = "./mysql"

  name               = "${var.name}-mysql"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = "${var.vpc_cidr}"
  public_subnets     = "${var.public_subnets}"
  private_subnet_ids = "${var.private_subnet_ids}"
  key_name           = "${var.key_name}"
  instance_type      = "${var.mysql_instance_type}"
  ami_id             = "${var.mysql_instance_ami_id}"
  bastion_public_ip  = "${var.bastion_public_ip}"
  bastion_user       = "${var.bastion_user}"
}

output "mysql_private_ips" { value = "${module.mysql.private_ips}" }
