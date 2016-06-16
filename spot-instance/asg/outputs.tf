output "launch_configuration_id" {
  value = "${aws_launch_configuration.as_conf.id}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.asg.id}"
}
