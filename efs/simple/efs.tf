resource "aws_efs_file_system" "efs" {
  performance_mode = "generalPurpose"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_efs_mount_target" "efs" {
  file_system_id  = "${aws_efs_file_system.efs.id}"
  subnet_id       = "${aws_subnet.public.id}"
  security_groups = ["${aws_security_group.efs.id}"]
}
