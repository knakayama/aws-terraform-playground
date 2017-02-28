variable "name" {}

variable "vpc_cidr" {}

data "aws_availability_zones" "az" {}

data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}
