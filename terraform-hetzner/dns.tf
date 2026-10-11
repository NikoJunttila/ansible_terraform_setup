# Cloudflare DNS for junttila.dev (moved from Squarespace DNS; Squarespace stays registrar)

resource "cloudflare_zone" "main" {
  account = {
    id = var.cloudflare_account_id
  }
  name = var.domain
  type = "full"
}

locals {
  # Subdomains served by the Caddy reverse proxy on the Hetzner VPS
  vps_subdomains = [
    "@",
    "alloy",
    "analytics",
    "backend.pi",
    "booking",
    "books",
    "freelance",
    "grafana",
    "jellyfin",
    "json",
    "memos",
    "ocis",
    "passwords",
    "passwords.pi",
    "pocket",
    "status",
    "store",
    "vendure",
    "woo",
  ]

  # Everything that doesn't point at the VPS
  other_records = {
    # Firebase hosting
    "www-a"  = { name = "www", type = "A", content = "199.36.158.100" }
    "gym"    = { name = "gym", type = "CNAME", content = "portfolio-5756d.web.app" }
    "google" = { name = "r4q75zgdxvo4", type = "CNAME", content = "gv-izqqmrtsdaroud.dv.googlehosted.com" }

    # Work (hur)
    "hur"          = { name = "hur", type = "A", content = "204.168.176.231" }
    "hurstatus"    = { name = "hurstatus", type = "A", content = "204.168.176.231" }
    
    # Squarespace email forwarding (Mailgun)
    "mx-a"     = { name = "@", type = "MX", content = "mxa.mailgun.org", priority = 10 }
    "mx-b"     = { name = "@", type = "MX", content = "mxb.mailgun.org", priority = 10 }
    "spf-apex" = { name = "@", type = "TXT", content = "v=spf1 include:mailgun.org ~all" }
    "dmarc"    = { name = "_dmarc", type = "TXT", content = "v=DMARC1; p=none;" }

    # Mailgun (mg subdomain)
    "mg-mx-a"  = { name = "mg", type = "MX", content = "mxa.eu.mailgun.org", priority = 10 }
    "mg-mx-b"  = { name = "mg", type = "MX", content = "mxb.eu.mailgun.org", priority = 10 }
    "mg-spf"   = { name = "mg", type = "TXT", content = "v=spf1 include:mailgun.org ~all" }
    "mg-dkim"  = { name = "s1._domainkey.mg", type = "TXT", content = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC647+pWGchtm2iDEA93IcK2MGCF9rzTnJUu13lKM7AguV63nDJGWgEPPlcpk5cmwj/xKOS1XlRl9NoqRYSYunMMIohvJa7sLFvcYOSIZB1EVM/huE1NL86z3Z8MsLIythbGwgU2JBYtedGx8+gKa0psXhjoNBwm8ZrbBscICrRPQIDAQAB" }
    "mg-dmarc" = { name = "_dmarc.mg", type = "TXT", content = "v=DMARC1; p=none; pct=100; fo=1; ri=3600; rua=mailto:f51b1041@dmarc.mailgun.org,mailto:bf2ebc8f@inbox.ondmarc.com; ruf=mailto:f51b1041@dmarc.mailgun.org,mailto:bf2ebc8f@inbox.ondmarc.com;" }
    "mg-track" = { name = "email.mg", type = "CNAME", content = "eu.mailgun.org" }

    # Amazon SES / Resend
    "ses-inbound"  = { name = "email", type = "MX", content = "inbound-smtp.eu-west-1.amazonaws.com", priority = 10 }
    "ses-send-mx"  = { name = "send", type = "MX", content = "feedback-smtp.eu-west-1.amazonses.com", priority = 10 }
    "ses-send-spf" = { name = "send", type = "TXT", content = "v=spf1 include:amazonses.com ~all" }
    "resend-dkim"  = { name = "resend._domainkey", type = "TXT", content = "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCzP7hqT9J0wIr23cKLJOb2mv0d2c6KtBUOUysZAwwZv5FJtoQxRw6ZQy/xhW8aNUtfEz7Hzxnz9LZsquFzr9eM3f6JSnkVh66n0xySx5ywV0NxPoCqLXih/GIgBy60Y3ZO9EFFZGLqMpj2g39nw/Goi8ec16Z8dmWXUIpoe5sUWQIDAQAB" }
    "smtp-dkim"    = { name = "smtp._domainkey", type = "TXT", content = "k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYLo+gye6tWk1gaONHieR+dYNtvC/vvwUpAKezTzvF7kIdiUbPgoX6INO18LrdesNQWoVTrZv1p4v+XAVIeD7TKXtU7IHhcSezUb5JZfc1/W4x2wlSU5Icar2Xg71CXPNEwfrKN6ew14nTSxJ8GBCdjwKE+avLNc18jDRIDjq1VQIDAQAB" }
  }
}

# Cloudflare stores full names, so "@" -> apex and "sub" -> "sub.<domain>"
resource "cloudflare_dns_record" "vps" {
  for_each = toset(local.vps_subdomains)

  zone_id = cloudflare_zone.main.id
  name    = each.key == "@" ? var.domain : "${each.key}.${var.domain}"
  type    = "A"
  content = hcloud_server.web.ipv4_address
  ttl     = 1 # automatic
  proxied = false
}

resource "cloudflare_dns_record" "other" {
  for_each = local.other_records

  zone_id  = cloudflare_zone.main.id
  name     = each.value.name == "@" ? var.domain : "${each.value.name}.${var.domain}"
  type     = each.value.type
  content  = each.value.content
  priority = lookup(each.value, "priority", null)
  ttl      = 1 # automatic
  proxied  = false
}
