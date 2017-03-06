resource "aws_efs_file_system" "efs" {
  count            = 2
  creation_token   = "${var.env}-${count.index}"
  performance_mode = "generalPurpose"

  tags {
    Name = "${var.env}-${count.index}"
  }
}

resource "aws_efs_mount_target" "efs" {
  count           = 2
  file_system_id  = "${element(aws_efs_file_system.efs.*.id, count.index)}"
  subnet_id       = "${data.aws_subnet.selected.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}
