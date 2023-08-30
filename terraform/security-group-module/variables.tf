variable "name" {
  type    = string
  default = "sg"
}

variable "vpc_id" {
  type    = string
  default = "vpc-0d2831659ef89870c"
}

variable "tags" {
  type    = map(string)
  default = {}
}
