resource "aws_key_pair" "key_pair" {
  key_name   = "${var.name}-key-pair"
  public_key = "${file("${path.module}/keys/site_key.pub")}"
}
