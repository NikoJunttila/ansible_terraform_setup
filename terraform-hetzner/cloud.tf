terraform {
  cloud {
    organization = "randomderp"

    workspaces {
      name = "hetzner-vps"
    }
  }
}
