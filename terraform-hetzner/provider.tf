terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
      #TODO have version updated to latest instead of being 1.45?
      # How to check current version?
      # version = "~> 1.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.27"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

# reads the token from the CLOUDFLARE_API_TOKEN env var
provider "cloudflare" {}
