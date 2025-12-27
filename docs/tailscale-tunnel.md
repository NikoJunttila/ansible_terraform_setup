I have created a document explaining how to set up Tailscale for your use case: docs/tailscale-tunnel.md.

It covers two approaches:

Tailscale Funnel (Simplest): Uses Tailscale's infrastructure directly. No VPS needed, but limited to specific ports and uses a *.ts.net domain.
VPS as a Reverse Proxy (More Control): Your VPS acts as the public entry point with your own domain. Nginx on the VPS proxies traffic over the Tailscale network to your Pi.
Given your setup, the VPS Proxy approach seems best for a production-like environment with a custom domain.

# Tailscale Tunnel Setup Guide

This document explains how to expose services running on a home Raspberry Pi (or EC2 instance for testing) to the public internet **without opening ports on your router**, using Tailscale.

## Goal

```
Internet User --> VPS (Public IP) --> Tailscale Network --> Raspberry Pi (Home)
```

The user accesses the VPS's public IP, Tailscale tunnels the traffic to the Pi.

---

## Option 1: Tailscale Funnel (Simplest)

Tailscale Funnel lets you expose a local service to the internet using Tailscale's infrastructure. No VPS needed.

**Pros:**
- No VPS required.
- Automatic HTTPS with Let's Encrypt.
- Super easy to set up.

**Cons:**
- Limited to ports 443, 8443, 10000.
- URL is `yournode.tailnet.ts.net` (not your own domain easily).
- Subject to Tailscale bandwidth limits.

### Setup

1.  **Install Tailscale** on your Pi/EC2:
    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up
    ```

2.  **Enable Funnel** for your service (e.g., Vaultwarden on port 80):
    ```bash
    # Expose local port 80 on the public internet via Funnel
    sudo tailscale funnel 80
    ```
    
3.  Tailscale will print a URL like `https://yourpi.your-tailnet.ts.net`. Share this URL.

---

## Option 2: VPS as a Reverse Proxy (More Control)

Use your VPS as the public entry point, and Tailscale to connect it to your Pi.

**Pros:**
- Full control over your domain and ports.
- No Tailscale bandwidth limitations for the tunnel itself.
- Your own domain name with your own SSL certs.

**Cons:**
- More setup involved.
- Requires a VPS with a public IP.

### Architecture

```
                        ┌─────────────────────────────────────┐
                        │            Tailscale Network         │
                        │  (Encrypted, Point-to-Point)         │
                        │                                      │
  ┌─────────────┐       │   ┌───────────────┐   ┌───────────────┐
  │  Internet   │──────▶│───│   VPS         │───│   Raspberry Pi │
  │   User      │       │   │ (Nginx Proxy) │   │ (Vaultwarden)  │
  └─────────────┘       │   │ 100.x.x.x     │   │ 100.y.y.y      │
                        │   └───────────────┘   └───────────────┘
                        └─────────────────────────────────────┘
```

### Setup

#### Step 1: Install Tailscale on Both Machines

On **VPS**:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

On **Raspberry Pi**:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

After both are connected, find their Tailscale IPs:
```bash
tailscale ip -4
```
- VPS: e.g., `100.100.100.1`
- Pi: e.g., `100.100.100.2`

#### Step 2: Configure Nginx on the VPS

Install Nginx: "actually use caddy here"
```bash
sudo apt update && sudo apt install nginx -y
```

Create a reverse proxy config (`/etc/nginx/sites-available/vaultwarden`):
```nginx
server {
    listen 80;
    server_name yourdomain.com;  # or VPS public IP

    location / {
        proxy_pass http://100.100.100.2:80;  # Pi's Tailscale IP
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable and restart:
```bash
sudo ln -s /etc/nginx/sites-available/vaultwarden /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl reload nginx
```

#### Step 3: (Optional) Add HTTPS with Certbot

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

---

## Summary

| Feature          | Tailscale Funnel | VPS Proxy         |
| ---------------- | ---------------- | ----------------- |
| Custom Domain    | No               | Yes               |
| Custom Ports     | Limited (443)   | Any               |
| No VPS Needed    | Yes              | No                |
| Setup Complexity | Low              | Medium            |
| Bandwidth        | Tailscale limits | Your VPS provider |

**Recommendation:** Start with **Tailscale Funnel** for quick testing. For production with a custom domain, use the **VPS Proxy** approach.
