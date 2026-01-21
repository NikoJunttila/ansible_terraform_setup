resource "hcloud_ssh_key" "default" {
  name       = "terraform-key"
  public_key = file(pathexpand(var.public_key_path))
}

resource "hcloud_server" "web" {
  name        = "web-server"
  image       = var.image
  server_type = var.server_type
  location    = var.location
  ssh_keys    = [hcloud_ssh_key.default.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
