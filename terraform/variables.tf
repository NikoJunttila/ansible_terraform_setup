variable "region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"
}

variable "instance_type" {
  description = "EC2 Instance Type (ARM based) - t4g.small recommended for all apps"
  type        = string
  default     = "t4g.small"  # 2GB RAM - needed for Karakeep/Meilisearch
}

variable "key_name" {
  description = "Name of the SSH key pair to create in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public key file to upload to AWS"
  type        = string
  default     = "~/.ssh/ansible-lab.pub"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to SSH"
  type        = string
  default     = "0.0.0.0/0"
}
