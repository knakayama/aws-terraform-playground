variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_public_key" {}
variable "aws_private_key" {}
variable "aws_region" {
  default = "ap-northeast-1"
}
variable "aws_ami" {
  description = "Amazon Linux"
  default = "ami-383c1956"
}
variable "aws_mysql_engine_version" {
  default = "5.6.23"
}
variable "aws_db_username" {
  default = "wordpress"
}
variable "aws_db_password" {
  default = "wordpress"
}
