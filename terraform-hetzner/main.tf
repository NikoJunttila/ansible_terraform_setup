# create ssh key
resource "hcloud_ssh_key" "default" {
  name       = "terraform-key"
  public_key = file(pathexpand(var.public_key_path))
}

# create server
resource "hcloud_server" "web" {
  name        = "web-server"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  user_data = <<-EOT
    #cloud-config
    users:
      - name: ${var.ssh_user}
        groups: sudo
        shell: /bin/bash
        sudo: ['ALL=(ALL) NOPASSWD:ALL']
        ssh_authorized_keys:
          - ${file(pathexpand(var.public_key_path))}
  EOT

  public_net {
    ipv4_enabled = true
    # ipv6_enabled = true
  }
}
