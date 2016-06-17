provider "aws" {
  region = "ap-northeast-1"
}

data "aws_s3_bucket_object" "lambda" {
  bucket = "my-lambda-functions-knakayama"
  key    = "hello-world.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "cloudwatchlogs_full_access" {
  name       = "CloudWatchLogsFullAccess"
  roles      = ["${aws_iam_role.iam_for_lambda.name}"]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_lambda_function" "test_lambda" {
  s3_bucket         = "${data.aws_s3_bucket_object.lambda.bucket}"
  s3_key            = "${data.aws_s3_bucket_object.lambda.key}"
  s3_object_version = "${data.aws_s3_bucket_object.lambda.version_id}"
  function_name     = "lambda_function_name"
  role              = "${aws_iam_role.iam_for_lambda.arn}"
  handler           = "main.lambda_handler"
  runtime           = "python2.7"
}
