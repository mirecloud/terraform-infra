terraform {
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
