terraform {


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
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

