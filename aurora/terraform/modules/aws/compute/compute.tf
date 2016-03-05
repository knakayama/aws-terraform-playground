variable "name"                { }
variable "vpc_id"              { }
variable "azs"                 { }
variable "key_name"            { }
variable "public_subnet_ids"   { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

module "web" {
  source = "./web"

  name                = "${var.name}"
  vpc_id              = "${var.vpc_id}"
  azs                 = "${var.azs}"
  key_name            = "${var.key_name}"
  public_subnet_ids   = "${var.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

output "web_public_ips"        { value = "${module.web.web_public_ips}" }
output "elb_dns_name"          { value = "${module.web.elb_dns_name}" }
output "web_security_group_id" { value = "${module.web.security_group_id}" }
