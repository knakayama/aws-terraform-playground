variable name            { }
variable region          { }
variable site_public_key { }

variable vpc_cidr       { }
variable azs            { }
variable public_subnets { }

variable web_instance_type   { }
variable web_instance_ami_id { }

provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "site_key" {
  key_name   = "site_key"
  public_key = "${var.site_public_key}"
}

module "network" {
  source = "../../../modules/aws/network"

  name             = "${var.name}"
  vpc_cidr         = "${var.vpc_cidr}"
  azs              = "${var.azs}"
  public_subnets   = "${var.public_subnets}"
  web_instance_ids = "${module.compute.web_instance_ids}"
}

module "compute" {
  source = "../../../modules/aws/compute"

  name                = "${var.name}"
  vpc_id              = "${module.network.vpc_id}"
  key_name            = "${aws_key_pair.site_key.key_name}"
  azs                 = "${var.azs}"
  public_subnet_ids   = "${module.network.public_subnet_ids}"
  web_instance_type   = "${var.web_instance_type}"
  web_instance_ami_id = "${var.web_instance_ami_id}"
}

output "configuration" {
  value = <<EOT

Web:
  web_public_ips: "${join(" ", split(",", module.compute.web_public_ips))}"

ELB:
  elb_dns_name: "${module.network.elb_dns_name}"
EOT
}
