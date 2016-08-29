resource "aws_iam_role" "role_for_rds" {
  name               = "${var.name}-role"
  assume_role_policy = "${file("${path.module}/policies/rds_assume_role_policy.json")}"
}

resource "aws_iam_policy_attachment" "role_for_rds" {
  name       = "RDSEnhancedMonitoringRole"
  roles      = ["${aws_iam_role.role_for_rds.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
