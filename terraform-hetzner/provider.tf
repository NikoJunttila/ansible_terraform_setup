terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
      #TODO have version updated to latest instead of being 1.45?
      # How to check current version?
      # version = "~> 1.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}
