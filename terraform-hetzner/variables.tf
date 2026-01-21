variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

variable "public_key_path" {
  description = "Path to the public SSH key file"
  type        = string
  default     = "~/.ssh/hcloud-key.pub"
}

variable "server_type" {
  description = "The type of the server"
  type        = string
  default     = "cx22"
}

variable "location" {
  description = "The location of the server"
  type        = string
  default     = "nbg1"
}

variable "image" {
  description = "The image of the server"
  type        = string
  default     = "ubuntu-24.04"
}
