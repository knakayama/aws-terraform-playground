variable "name"                { }
variable "region"              { }
variable "vpc_id"              { }
variable "public_subnet_id"    { }
variable "private_subnet_id"   { }
variable "key_name"            { }
variable "ec2_instance_type"   { }
variable "ec2_instance_ami_id" { }

module "web" {
  source = "./web"

  name             = "${var.name}-web"
  vpc_id           = "${var.vpc_id}"
  public_subnet_id = "${var.public_subnet_id}"
  key_name         = "${var.key_name}"
  instance_type    = "${var.ec2_instance_type}"
  ami_id           = "${var.ec2_instance_ami_id}"
}

module "db" {
  source = "./db"

  name                  = "${var.name}-db"
  vpc_id                = "${var.vpc_id}"
  public_subnet_id      = "${var.public_subnet_id}"
  private_subnet_id     = "${var.private_subnet_id}"
  web_security_group_id = "${module.web.security_group_id}"
  key_name              = "${var.key_name}"
  instance_type         = "${var.ec2_instance_type}"
  ami_id                = "${var.ec2_instance_ami_id}"
}

output "web_public_ip" { value = "${module.web.public_ip}" }
output "db_private_ip" { value = "${module.db.private_ip}" }
