variable "name"                       { default = "cloudwatch" }
variable "sns_topic_subscription_arn" { }
variable "web_instance_id"            { }
variable "rds_instance_id"            { }
variable "s3_bucket_id"               { }

resource "aws_cloudwatch_metric_alarm" "cloudwatch_web" {
  alarm_name                = "${var.name}-web"
  alarm_description         = "Web CPU Monitoring"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 80
  alarm_actions             = ["${var.sns_topic_subscription_arn}"]
  insufficient_data_actions = ["${var.sns_topic_subscription_arn}"]
  ok_actions                = ["${var.sns_topic_subscription_arn}"]

  dimensions {
    InstanceId = "${var.web_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_rds" {
  alarm_name                = "${var.name}-rds"
  alarm_description         = "RDS Connection Numbers"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/RDS"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 10
  alarm_actions             = ["${var.sns_topic_subscription_arn}"]
  insufficient_data_actions = ["${var.sns_topic_subscription_arn}"]
  ok_actions                = ["${var.sns_topic_subscription_arn}"]

  dimensions {
    DBInstanceIdentifier = "${var.rds_instance_id}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch_s3" {
  alarm_name                = "${var.name}-s3"
  alarm_description         = "S3 Bucket Usage"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "BucketSizeBytes"
  namespace                 = "AWS/S3"
  period                    = 86400
  statistic                 = "Average"
  threshold                 = 1000000000
  alarm_actions             = ["${var.sns_topic_subscription_arn}"]
  insufficient_data_actions = ["${var.sns_topic_subscription_arn}"]
  ok_actions                = ["${var.sns_topic_subscription_arn}"]

  dimensions {
    BucketName = "${var.s3_bucket_id}"
  }
}
