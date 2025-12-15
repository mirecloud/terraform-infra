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

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "associate_public_ip_address" {
  description = "Associate public IP address to the instance"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Enable monitoring for the instance"
  type        = bool
  default     = true
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = list(string)
  default     = ["10.0.0.0/16", "10.0.1.0/24", "172.16.0.0/16"]
}

variable "allowed_vm_type" {
  description = "Allowed VM types"
  type        = list(string)
  default     = ["t2.micro", "t2.small", "t2.medium", "t2.large"]
}

variable "tags" {
  description = "Tags for the instance"
  type        = map(string)
  default = {
    Name        = "dev-mirecloud-machine"
    Environment = "dev"
    created_by  = "terraform"
  }
}


variable "ingress_values" {
  description = "Ingress values for the security group"
  type        = tuple([number, string, number])
  default     = [443, "tcp", 443]
}

variable "config" {
  description = "Configuration for the instance"
  type = object({
    region         = string,
    monitoring     = bool,
    instance_count = number
  })
  default = {
    region         = "us-east-1",
    monitoring     = true,
    instance_count = 1
  }
}
