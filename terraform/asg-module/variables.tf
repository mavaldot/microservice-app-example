variable "name" {
    type = string
    default = "ec2-launch" 
}

variable "image_id" {
    type = string
    default = "ami-09f67f6dc966a7829"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}

variable "key_name" {
    type = string
}

variable "responsible" {
    type = string
    default = "mateo.valdeso"
}

variable "project" {
    type = string
    default = "ramp-up-devops"
}

variable "user_data" {
    type = string
}

variable "vpc_security_group_ids" {
    type = list(string)
}

variable "vpc_zone_identifier" {
    type = list(string)
}
