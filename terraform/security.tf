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

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Pi-hole DNS
  ingress {
    description = "DNS UDP"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "DNS TCP"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Pi-hole Admin (moved to 8081 to avoid conflict with Vaultwarden on 80)
  ingress {
    description = "Pi-hole Admin"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jellyfin
  ingress {
    description = "Jellyfin HTTP"
    from_port   = 8096
    to_port     = 8096
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Shiori
  ingress {
    description = "Shiori Web"
    from_port   = 8100
    to_port     = 8100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # qBittorrent
  ingress {
    description = "qBittorrent Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "BitTorrent"
    from_port   = 6881
    to_port     = 6881
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "BitTorrent UDP"
    from_port   = 6881
    to_port     = 6881
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
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
