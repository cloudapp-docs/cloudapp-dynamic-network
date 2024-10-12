# 云应用系统变量，主要是镜像仓库相关变量
variable "cloudapp_cam_role" {}
variable "cloudapp_repo_server" {}
variable "cloudapp_repo_username" {}
variable "cloudapp_repo_password" {}

variable "app_name" {
  type    = string
  default = "cloudapp-demo-todo-list"
}
variable "vpc_cidr_block" {
  type    = string
  default = "10.0.5.0/24"
}
variable "subnet_cidr_block" {
  type    = string
  default = "10.0.5.0/25"
}
variable "app_cvm" {
  type = object({
    instance_type = string
  })
  default = {
    instance_type = "S6.MEDIUM4"
  }
}

variable "app_cvm_image" {
  type = object({
    image_id = string
  })

  default = {
    image_id = "img-mmytdhbn"
  }
}

# 用户选择的地域
variable "app_zone" {
  type = object({
    region = string
    zone   = string
  })
  default = {
    region = "ap-beijing"
    zone   = ""
  }
}

# 用户选择的安装目标位置，VPC 和子网，在 package.yaml 中定义了输入组件
variable "app_network_vpc" {
  type = object({
    region            = string
    availability_zone = string
    region_id         = string
    vpc = object({
      id         = string
      cidr_block = string
    })
    subnet = object({
      id         = string
      cidr_block = string
      zone       = string
    })
  })
  default = {
    region            = "ap-beijing"
    availability_zone = "ap-beijing-6"
    region_id         = "6"
    vpc = object({
      id = ""
    })
    subnet = object({
      id   = ""
      zone = ""
    })
  }
}

variable "app_sg" {
  type = object({
    region    = string
    region_id = string
    security_group = object({
      id = string
    })
  })
  default = {
    region    = "ap-beijing"
    region_id = "6"
    security_group = object({
      id = ""
    })
  }
}

variable "charge_perpaid_auto_renew" {
  type    = bool
  default = false
}

variable "charge_type" {
  type    = string
  default = "POSTPAID"
}

variable "charge_perpaid_period" {
  type    = number
  default = 1
}

variable "network_source" {
  type    = string
  default = ""
}

# 容器网络
variable "cluster_cidr" {
  default = "172.16.0.0/16"
}