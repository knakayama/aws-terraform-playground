data "aws_iam_policy_document" "ec2" {
  statement {
    sid     = "EC2AssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = "${data.aws_iam_policy_document.ec2.json}"
}

resource "aws_iam_policy_attachment" "cloudwatch_full_access" {
  name       = "CloudWatchFullAccess"
  roles      = ["${aws_iam_role.ec2.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_policy_attachment" "ec2_role_for_ssm" {
  name       = "AmazonEC2RoleforSSM"
  roles      = ["${aws_iam_role.ec2.name}"]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "ec2" {
  name  = "${var.name}-ec2-profile"
  roles = ["${aws_iam_role.ec2.name}"]
}
