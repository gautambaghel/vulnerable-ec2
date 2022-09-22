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
  # WORKSHOP: Specify the region you like to use, especially if you plan on using your keypair to access your EC2 instance.
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
    # WORKSHOP: Modify the following line to a CIDR block specific to you, and uncomment the next line with 0.0.0.0
    # This line allows SSH access from any IP address
#    cidr_blocks      = ["0.0.0.0/0"]
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
    # WORKSHOP: Modify the following line to a CIDR block specific to you, and uncomment the next line with 0.0.0.0
    # This line allows HTTP access from any IP address
#    cidr_blocks      = ["0.0.0.0/0"]
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

  user_data = <<-EOF
    #!/bin/bash
    # install httpd (Linux 2 version)
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from the AWS HashiCorp + Snyk Workshop on $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  # WORKSHOP: Add the name of your key here
#  key_name = "mam-workshop-keypair"

  # WORKSHOP: uncomment the lines below to enable encrypted block device
#  root_block_device {
#    encrypted = true
#  }


}

output "ec2_url" {
  value = aws_instance.ec2.public_dns
}