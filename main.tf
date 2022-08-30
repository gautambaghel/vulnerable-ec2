terraform {

  cloud {
    organization = "organization-name-here"

    workspaces {
      name = "workspace-name-here"
    }
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.28.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
}

resource "aws_security_group" "allow_ssh_from_anywhere" {
  name        = "allow_ssh_from_anywhere"
  description = "Allow SSH inbound traffic from anywhere"

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_ssh_from_anywhere"
  }
}

resource "aws_security_group" "allow_port_80_from_anywhere" {
  name        = "allow_port_80_from_anywhere"
  description = "Allow port 80 inbound traffic from anywhere"

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_port_80_from_anywhere"
  }
}

data "aws_ami" "amazon2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"] # Canonical
}

resource "aws_instance" "ec2" {
  ami           = data.aws_ami.amazon2.id
  instance_type = "t3.nano"
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.allow_ssh_from_anywhere.id, aws_security_group.allow_port_80_from_anywhere.id]
}