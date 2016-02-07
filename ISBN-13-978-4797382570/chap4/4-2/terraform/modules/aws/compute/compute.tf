variable "name"                { }
variable "region"              { }
variable "vpc_id"              { }
variable "public_subnet_id"    { }
variable "key_name"            { }
variable "private_key"         { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "role_policy"         { }
variable "assume_role_policy"  { }

module "web" {
  source = "./web"

  name               = "${var.name}-web"
  region             = "${var.region}"
  vpc_id             = "${var.vpc_id}"
  public_subnet_id   = "${var.public_subnet_id}"
  key_name           = "${var.key_name}"
  private_key        = "${var.private_key}"
  instance_type      = "${var.web_instance_type}"
  instance_ami_id    = "${var.web_instance_ami_id}"
  role_policy        = "${var.role_policy}"
  assume_role_policy = "${var.assume_role_policy}"
}

output "web_public_ip" { value = "${module.web.public_ip}" }
