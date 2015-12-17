variable name                { }
variable region              { }
variable site_public_key     { }

variable vpc_cidr       { }
variable azs            { }
variable public_subnets { }

variable web_instance_type   { }
variable web_instance_ami_id { }

provider "aws" {
  region     = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name = "chap2_site_key"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name           = "${var.name}"
  vpc_cidr       = "${var.vpc_cidr}"
  azs            = "${var.azs}"
  region         = "${var.region}"
  public_subnets = "${var.public_subnets}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

output "web_public_ip"     { value = "${module.compute.web_public_ip}" }
