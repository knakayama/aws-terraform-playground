data "external" "my_ip" {
  program = ["python", "${path.module}/external/my-ip.py"]
}
