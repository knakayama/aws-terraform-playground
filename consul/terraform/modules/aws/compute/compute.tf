variable "name"                { }
variable "region"              { }
variable "key_name"            { }
variable "key_file"            { }
variable "vpc_ids"             { }
variable "azs"                 { }
variable "public_subnet_ids"   { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "web_platform"        { }

module "web" {
  source = "./web"

  name              = "${var.name}-web"
  region            = "${var.region}"
  key_name          = "${var.key_name}"
  key_file          = "${var.key_file}"
  vpc_ids           = "${var.vpc_ids}"
  azs               = "${var.azs}"
  public_subnet_ids = "${var.public_subnet_ids}"
  instance_type     = "${var.web_instance_type}"
  instance_ami_id   = "${var.web_instance_ami_id}"
  platform          = "${var.web_platform}"
}

output "web_public_ips"  { value = "${module.web.public_ips}" }
output "web_private_ips" { value = "${module.web.private_ips}" }
