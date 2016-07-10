resource "aws_key_pair" "site_key" {
  key_name   = "${var.name}"
  public_key = "${file("site_key.pub")}"
}

resource "aws_spot_fleet_request" "fleet" {
  iam_fleet_role      = "${aws_iam_role.fleet_role.arn}"
  spot_price          = "${var.spot_prices["main"]}"
  allocation_strategy = "diversified"
  target_capacity     = 1
  valid_until         = "2019-11-04T20:44:20Z"

  launch_specification {
    instance_type               = "${var.instance_types["m3_medium"]}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    key_name                    = "${aws_key_pair.site_key.key_name}"
    spot_price                  = "${var.spot_prices["m3_medium"]}"
    availability_zone           = "${data.aws_availability_zones.az.names[0]}"
    subnet_id                   = "${aws_subnet.public.0.id}"
    vpc_security_group_ids      = ["${aws_security_group.web.id}"]
    associate_public_ip_address = true

    root_block_device {
      volume_size = "8"
      volume_type = "gp2"
    }
  }

  launch_specification {
    instance_type               = "${var.instance_types["m3_large"]}"
    ami                         = "${data.aws_ami.amazon_linux.id}"
    key_name                    = "${aws_key_pair.site_key.key_name}"
    spot_price                  = "${var.spot_prices["m3_large"]}"
    availability_zone           = "${data.aws_availability_zones.az.names[1]}"
    subnet_id                   = "${aws_subnet.public.1.id}"
    vpc_security_group_ids      = ["${aws_security_group.web.id}"]
    associate_public_ip_address = true

    #weighted_capacity = 35

    root_block_device {
      volume_size = "8"
      volume_type = "gp2"
    }
  }
}
