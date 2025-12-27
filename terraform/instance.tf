data "aws_ami" "ubuntu_arm" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "lab_instance" {
  ami           = data.aws_ami.ubuntu_arm.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.lab_key.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name        = "arm-ansible-lab-instance"
    Description = "ARM64 instance for Ansible testing"
    AutoKill    = "24h"
  }
}
