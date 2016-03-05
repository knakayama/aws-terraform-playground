variable "name"                    { }
variable "vpc_id"                  { }
variable "key_name"                { }
variable "azs"                     { }
variable "public_subnet_id"        { }
variable "private_subnet_id"       { }
variable "ec2_instance_type"       { }
variable "ec2_instance_ami_id"     { }
variable "bastion_artifact_ami_id" { }

module "bastion" {
  source = "./bastion"

  name             = "${var.name}-bastion"
  vpc_id           = "${var.vpc_id}"
  key_name         = "${var.key_name}"
  public_subnet_id = "${var.public_subnet_id}"
  instance_type    = "${var.ec2_instance_type}"
  instance_ami_id  = "${var.bastion_artifact_ami_id}"
}

module "web" {
  source = "./web"

  name                      = "${var.name}-web"
  vpc_id                    = "${var.vpc_id}"
  key_name                  = "${var.key_name}"
  private_subnet_id         = "${var.private_subnet_id}"
  instance_type             = "${var.ec2_instance_type}"
  instance_ami_id           = "${var.ec2_instance_ami_id}"
  bastion_security_group_id = "${module.bastion.security_group_id}"
}

module "db" {
  source = "./db"

  name                      = "${var.name}-db"
  vpc_id                    = "${var.vpc_id}"
  key_name                  = "${var.key_name}"
  private_subnet_id         = "${var.private_subnet_id}"
  instance_type             = "${var.ec2_instance_type}"
  instance_ami_id           = "${var.ec2_instance_ami_id}"
  bastion_security_group_id = "${module.bastion.security_group_id}"
}

output "bastion_public_ip" { value = "${module.bastion.public_ip}" }
output "web_private_ip"    { value = "${module.web.private_ip}" }
output "db_private_ip"     { value = "${module.db.private_ip}" }
