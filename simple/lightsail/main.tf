provider "aws" {
  region = "us-east-1"
}

data "external" "wp_blueprint_id" {
  program = ["bash", "${path.module}/get-blueprints.sh"]

  query = {
    group = "wordpress"
  }
}

resource "aws_lightsail_key_pair" "key_pair" {
  public_key = "${file("${path.module}/keys/key_pair.pub")}"
}

resource "aws_lightsail_instance" "wp" {
  name              = "wp"
  availability_zone = "us-east-1b"
  blueprint_id      = "${data.external.wp_blueprint_id.result["WpBlueprintId"]}"
  bundle_id         = "nano_1_0"
  key_pair_name     = "${aws_lightsail_key_pair.key_pair.id}"
}
