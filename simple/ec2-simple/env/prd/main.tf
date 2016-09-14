provider "aws" {
  region = "${var.region}"
}

module "main" {
  source = "../.."

  name        = "${var.name}"
  vpc_cidr    = "${var.vpc_cidr}"
  spot_config = "${var.spot_config}"
}
