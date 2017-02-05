resource "aws_cloudwatch_metric_alarm" "test" {
  alarm_name          = "test"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [
    "arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.sns_topic}",
    "${data.external.scaling_policy.result["policy_arn"]}",
  ]
}
