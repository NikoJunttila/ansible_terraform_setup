resource "aws_security_group" "lab_sg" {
  name        = "arm-ansible-lab-sg"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH from allowed CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "arm-ansible-lab-sg"
  }
}

resource "aws_key_pair" "lab_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}
