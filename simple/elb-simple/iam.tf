data "aws_iam_policy_document" "ec2" {
  statement {
    sid     = "EC2AssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.name}-ec2-role"
  assume_role_policy = "${data.aws_iam_policy_document.ec2.json}"
}

resource "aws_iam_policy_attachment" "cloudwatch_full_access" {
  name       = "CloudWatchFullAccess"
  roles      = ["${aws_iam_role.ec2_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_policy_attachment" "s3_full_access" {
  name       = "S3FullAccess"
  roles      = ["${aws_iam_role.ec2_role.name}"]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.name}-instance-profile"
  role = "${aws_iam_role.ec2_role.name}"
}
