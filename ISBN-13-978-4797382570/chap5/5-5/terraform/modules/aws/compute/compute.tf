variable "name"                { }
variable "region"              { }
variable "vpc_id"              { }
variable "azs"                 { }
variable "key_name"            { }
variable "public_subnet_ids"   { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "max_size"            { }
variable "min_size"            { }

module "web" {
  source = "./web"

  name              = "${var.name}-web"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  azs               = "${var.azs}"
  key_name          = "${var.key_name}"
  public_subnet_ids = "${var.public_subnet_ids}"
  instance_type     = "${var.web_instance_type}"
  instance_ami_id   = "${var.web_instance_ami_id}"
  max_size          = "${var.max_size}"
  min_size          = "${var.min_size}"
}

output "elb_dns_name" { value = "${module.web.elb_dns_name}" }
output "elb_zone_id"  { value = "${module.web.elb_zone_id}" }
