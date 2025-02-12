resource "aws_vpc" "Monitoring" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Monitoring"
  }
}

resource "aws_subnet" "Monitoring-subnet" {
  vpc_id            = aws_vpc.Monitoring.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Monitoring-subnet"
  }
}

resource "aws_network_interface" "prometheus" {
  subnet_id   = aws_subnet.Monitoring-subnet.id
  private_ips = ["10.0.1.100"]
  security_groups = [aws_security_group.prometheus-security-group.id] 
  tags = {
    Name = "prometheus_network_interface"
  }
}

resource "aws_network_interface" "grafana" {
  subnet_id   = aws_subnet.Monitoring-subnet.id
  private_ips = ["10.0.1.101"]
  security_groups = [aws_security_group.grafana-security-group.id] 
  tags = {
    Name = "grafana_network_interface"
  }
}
resource "aws_instance" "prometheus" {
  ami           = "ami-04b4f1a9cf54c11d0" # us-west-2
  instance_type = "t2.micro"
  
  network_interface {
    network_interface_id = aws_network_interface.prometheus.id

    device_index         = 0
  }

  key_name = aws_key_pair.Monitoring_key.key_name  

  tags = {
    Name = "Prometheus"
  }

}

resource "aws_instance" "grafana" {
  ami           = "ami-04b4f1a9cf54c11d0" # us-west-2
  instance_type = "t2.micro"
  
  network_interface {
    network_interface_id = aws_network_interface.grafana.id

    device_index         = 0
  }

  key_name = aws_key_pair.Monitoring_key.key_name  

  tags = {
    Name = "grafana"
  }

}

resource "aws_security_group" "grafana-security-group" {
 name        = "grafana-sg-tf"
 description = "Allow ssh prometheus and node exporter "
 vpc_id      = aws_vpc.Monitoring.id

tags = {
    Name = "grafana"
  }

ingress {
   description = "grafana port"
   from_port   = 3000
   to_port     = 3000
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "node exporter port"
   from_port   = 9100
   to_port     = 9100
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "ssh port"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


resource "aws_security_group" "prometheus-security-group" {
 name        = "prometheus-sg-tf"
 description = "Allow ssh prometheus and node exporter "
 vpc_id      = aws_vpc.Monitoring.id

tags = {
    Name = "Prometheus"
  }

ingress {
   description = "prometheus port"
   from_port   = 9090
   to_port     = 9090
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "prometheus port"
   from_port   = 9100
   to_port     = 9100
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

ingress {
   description = "prometheus port"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.Monitoring.id
 
 tags = {
   Name = "Project Monitoring"
 }
}

resource "aws_route_table" "Monitoring_rt" {
 vpc_id = aws_vpc.Monitoring.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }
 
 tags = {
   Name = "Monitoring Route Table"
 }
}

resource "aws_route_table_association" "monitoring_rt_assoc" {
  subnet_id      = aws_subnet.Monitoring-subnet.id
  route_table_id = aws_route_table.Monitoring_rt.id
}


resource "aws_key_pair" "Monitoring_key" {
  key_name   = "aws" # Choose a descriptive name
  public_key = file("/home/asd/.ssh/github.pub") # Path to your public key file
  tags = {
   Name = "Monitoring key"
 }
}

resource "null_resource" "update_inventory" {
  triggers = {
    instance_id = aws_instance.prometheus.id  # Se déclenche si l'instance change
  }

  provisioner "local-exec" {
    command = "python3 dynamic_inventory.py"
  }

  provisioner "local-exec" {
    command = "ansible-playbook prometheus.yml -i inventory.json "
  }
}
