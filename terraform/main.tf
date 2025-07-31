provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "allow_nifi" {
  name        = "allow_nifi"
  description = "Allow SSH, Jenkins, and NiFi"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for NiFi"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins"
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "nifi_instance" {
  ami           = "ami-04f167a56786e4b09"
  instance_type = "t2.medium"
  key_name      = "nifi"
  security_groups = [aws_security_group.allow_nifi.name]

  root_block_device {
    volume_size = 20
  }

  tags = {
    Name = "NiFi_Instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.nifi_instance.public_ip
}
