terraform {


  backend "s3" {
    bucket       = "mirecloud-bucket"
    key          = "pdev.terraform.tfstate"
    region       = "us-east-1"
    encrypt      = false
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

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

locals {
  env           = var.environment
  bucket_name   = "${var.channel}-bucket-${var.environment}-${var.region}"
  vpc_name      = "${var.channel}-vpc-${var.environment}-${var.region}"
  instance_name = "${var.channel}-instance-${var.environment}-${var.region}"

}
# Configure resource bucket

resource "aws_s3_bucket" "first_bucket" {
  bucket = local.bucket_name

  tags = {
    Name        = local.bucket_name
    Environment = var.environment
    Region      = var.region
  }
}

resource "aws_vpc" "first_mirecloud_vpc" {
  cidr_block = "10.0.0.0/16"
  region     = var.region

  tags = {
    Name        = local.vpc_name
    Environment = var.environment
  }
}

# --- AJOUT : CRÉATION DU SUBNET ---
resource "aws_subnet" "first_subnet" {
  vpc_id     = aws_vpc.first_mirecloud_vpc.id
  cidr_block = "10.0.1.0/24" # Une plage d'IP à l'intérieur du 10.0.0.0/16 du VPC

  tags = {
    Name        = "${var.channel}-subnet-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_instance" "first_instance" {
  ami           = "ami-068c0051b15cdb816"
  instance_type = "t2.micro"
  region        = var.region
  subnet_id     = aws_subnet.first_subnet.id

  tags = {
    Name        = local.instance_name
    Environment = var.environment
  }
}

output "bucket_name" {
  value = aws_s3_bucket.first_bucket.bucket
}

output "vpc_id" {
  value = aws_vpc.first_mirecloud_vpc.id
}

output "instance_id" {
  value = aws_instance.first_instance.id
}
