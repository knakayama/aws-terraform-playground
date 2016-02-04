variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "web_instance_type"   { }
variable "web_instance_ami_id" { }

variable "vpc_cidr"      { }
variable "public_subnet" { }
variable "az"            { }

variable "sns_topic_arn" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name          = "${var.name}"
  az            = "${var.az}"
  vpc_cidr      = "${var.vpc_cidr}"
  public_subnet = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
  sns_topic_arn       = "${var.sns_topic_arn}"
}

output "web_public_ip" { value = "${module.compute.web_public_ip}" }
