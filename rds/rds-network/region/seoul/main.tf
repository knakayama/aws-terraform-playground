provider "aws" {
  region = "${var.region}"
}

module "main" {
  source = "../.."

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  web_instance_type = "${var.web_instance_type}"
  azs               = "${data.aws_availability_zones.az.names}"
  amazon_linux_id   = "${data.aws_ami.amazon_linux.id}"
}
