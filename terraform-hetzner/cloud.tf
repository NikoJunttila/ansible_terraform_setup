# terraform cloud for saving state
terraform {
  cloud {
    organization = "randomderp"

    workspaces {
      name = "hetzner-vps"
    }
  }
}
