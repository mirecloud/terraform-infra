terraform {

 
  backend "s3" {
    bucket = "mirecloud-bucket"
    key    = "pdev.terraform.tfstate"
    region = "us-east-1"
    encrypt = false
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

# Configure resource bucket

resource "aws_s3_bucket" "first_bucket" {
  bucket = "mirecloud-bucket-name-123456"

  tags = {
    Name        = "mirecloud-bucket"
    Environment = "Dev"
  }
}
