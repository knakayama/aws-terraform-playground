variable "public_key" {
  default = "site_key.pub"
}

variable "access_cidr_blocks" {
  default = "0.0.0.0/0"
}

variable "name_prefix" {
  default = "spot-instance-simple"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "az" {
  default = "c"
}

variable "amis" {
  default = {
    web = "ami-6154bb00"
  }
}

variable "instance_types" {
  default = {
    web = "c3.large"
  }
}

variable "spot_prices" {
  default = {
    web = "0.133"
  }
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "wait_for_fulfillment" {
  default = true
}
