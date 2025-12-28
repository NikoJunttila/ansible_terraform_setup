# Use Ubuntu 22.04 ARM64 (for t4g instances) or x86 depending on instance type
data "aws_ami" "ubuntu" {
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

resource "aws_instance" "vps" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.vps_key.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.vps_sg.id]

  tags = {
    Name        = var.instance_name
    Description = "Public-facing VPS for reverse proxy via Tailscale"
    Purpose     = "reverse-proxy"
  }

  root_block_device {
    volume_size = 8  # 8GB is enough for a proxy
    volume_type = "gp3"
  }
}
