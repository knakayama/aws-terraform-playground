data "external" "scaling_policy" {
  program = ["python", "${path.module}/external/scaling_policy.py"]

  query = {
    policy_name = "${var.policy_name}"
  }
}
