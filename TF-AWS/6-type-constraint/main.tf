terraform {


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure resource bucket



# --- AJOUT : CRÉATION DU SUBNET ---


resource "aws_instance" "first_instance" {
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.monitoring
  count                       = var.instance_count
  ami                         = "ami-068c0051b15cdb816"
  instance_type               = var.allowed_vm_type[0]
  #region                      = var.region
  region = var.config.region

  tags = var.tags



}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.cidr_block[0]
  from_port         = var.ingress_values[0]
  ip_protocol       = var.ingress_values[1]
  to_port           = var.ingress_values[2]
}



resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


