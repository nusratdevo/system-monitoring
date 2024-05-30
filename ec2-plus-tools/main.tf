terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
}


resource "aws_security_group" "aws_sg" {
 name        = "monitoring-sg"
 description = "Allowing Jenkins, Sonarqube, SSH Access"

 ingress = [
    for port in [22,25, 80, 443,465, 6443, 8080, 9000, 5000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "devops-sg"
  }

}


resource "aws_instance" "aws_ins_web" {

  ami                         = "ami-04b70fa74e45c3917"
  instance_type               = "t2.large"
  vpc_security_group_ids      = [aws_security_group.aws_sg.id]
  associate_public_ip_address = true
  key_name                    = "devops" # your key here
  root_block_device {
    volume_size = 30
  }
  user_data = templatefile("./tools-install.sh", {})


  tags = {
    Name = "ec2-master"
  }

}

output "instance_ip" {
  value = aws_instance.aws_ins_web.public_ip
}