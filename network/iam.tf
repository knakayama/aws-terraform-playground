resource "aws_iam_role" "role_for_rds" {
  name = "rds-monitoring-role"

  assume_role_policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOT
}

resource "aws_iam_policy_attachment" "role_for_rds" {
  name       = "RDSEnhancedMonitoringRole"
  roles      = ["${aws_iam_role.role_for_rds.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
