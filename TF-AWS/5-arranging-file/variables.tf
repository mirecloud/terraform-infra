#variable declaration
variable "environment" {
  type    = string
  default = "dev"
}

variable "channel" {
  type    = string
  default = "mirecloud"
}

variable "region" {
  type    = string
  default = "us-east-1"
}
