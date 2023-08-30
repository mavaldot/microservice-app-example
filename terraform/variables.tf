variable "my_vpc" {
  type    = string
  default = "vpc-0d2831659ef89870c"
}

variable "private_subnet_1" {
  type    = string
  default = "subnet-0d74b59773148d704"
}

variable "private_subnet_2" {
  type    = string
  default = "subnet-038fa9d9a69d6561e"
}

variable "public_subnet_1" {
  type    = string
  default = "subnet-0088df5de3a4fe490"
}

variable "public_subnet_2" {
  type    = string
  default = "subnet-055c41fce697f9cca"
}

variable "project" {
  type    = string
  default = "ramp-up-devops"
}

variable "responsible" {
  type    = string
  default = "mateo.valdeso"
}

variable "docker_tag" {
  type = string
  default = "first"
}

variable "security_group_list" {
  type    = list(string)
  default = ["ec2-frontend-sg", "ec2-auth-sg", "ec2-lmp-sg", "ec2-todos-sg", "ec2-users-sg", "ec2-redis-sg", "ec2-zipkin-sg"]
}

variable "public_ssh_key" {
  type = string
  sensitive = true
}

variable "service_map" {
  type = map(object({
    port = number
    security_group = string
  }))
  default = {
    frontend = {
      port = 80
      security_group = "ec2-frontend-sg"
    }
    auth = {
      port = 8000
      security_group = "ec2-auth-sg"
    }
    lmp = {
      port = 9001
      security_group = "ec2-lmp-sg" 
    }
    todos = {
      port = 8082
      security_group = "ec2-todos-sg"
    }
    users = {
      port = 8083
      security_group = "ec2-users-sg"
    }
    zipkin = {
      port = 9411
      security_group = "ec2-zipkin-sg"
    }
  }
}