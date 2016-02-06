variable "name"            { }
variable "region"          { }
variable "site_public_key" { }

variable "vpc_cidr"       { }
variable "azs"            { }
variable "private_subnet" { }
variable "public_subnet"  { }

variable "ec2_instance_type"   { }
variable "ec2_instance_ami_id" { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  vpc_cidr       = "${var.vpc_cidr}"
  azs            = "${var.azs}"
  region         = "${var.region}"
  private_subnet = "${var.private_subnet}"
  public_subnet  = "${var.public_subnet}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  region              = "${var.region}"
  vpc_id              = "${module.network.vpc_id}"
  private_subnet_id   = "${module.network.private_subnet_id}"
  public_subnet_id    = "${module.network.public_subnet_id}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  ec2_instance_type   = "${var.ec2_instance_type}"
  ec2_instance_ami_id = "${var.ec2_instance_ami_id}"
}

output "web_public_ip" { value = "${module.compute.web_public_ip}" }
output "db_private_ip" { value = "${module.compute.db_private_ip}" }
