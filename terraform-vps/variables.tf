variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 Instance Type - t3.micro is the cheapest x86, t4g.nano is cheapest ARM"
  type        = string
  default     = "t4g.nano" # ~$3/month - cheapest option with ARM
}

variable "key_name" {
  description = "Name of the SSH key pair to create in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file to upload to AWS"
  type        = string
  default     = "~/.ssh/vps-proxy.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH (your IP for security)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_name" {
  description = "Name tag for the VPS instance"
  type        = string
  default     = "reverse-proxy-vps"
}
