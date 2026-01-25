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
  default     = "cx23"
  # CX23 Intel ® / AMD 2vcpu 4 GB ram 40 GB memory 20 TB bandwith
}

variable "location" {
  description = "The location of the server (helsinki)"
  type        = string
  default     = "hel1"
}

variable "image" {
  description = "The image of the server"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_user" {
  description = "The username for the SSH user"
  type        = string
  default     = "derp"
}
