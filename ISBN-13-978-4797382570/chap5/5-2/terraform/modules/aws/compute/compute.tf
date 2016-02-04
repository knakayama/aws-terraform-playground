variable "name"                { }
variable "region"              { }
variable "vpc_id"              { }
variable "key_name"            { }
variable "public_subnet_id"    { }
variable "web_instance_type"   { }
variable "web_instance_ami_id" { }
variable "sns_topic_arn"       { }

module "web" {
  source = "./web"

  name              = "${var.name}-web"
  region            = "${var.region}"
  vpc_id            = "${var.vpc_id}"
  key_name          = "${var.key_name}"
  public_subnet_id  = "${var.public_subnet_id}"
  instance_type     = "${var.web_instance_type}"
  instance_ami_id   = "${var.web_instance_ami_id}"
  sns_topic_arn     = "${var.sns_topic_arn}"
}

output "web_public_ip" { value = "${module.web.public_ip}" }
