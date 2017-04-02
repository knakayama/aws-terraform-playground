variable "name" {
  default = "env-test1"
}

variable "region" {
  default = "ap-northeast-1"
}

variable "dev_network_config" {
  default = {
    vpc_cidr = "192.168.0.0/16"
  }
}

variable "prod_network_config" {
  default = {
    vpc_cidr = "192.168.0.0/24"
  }
}
