# VPS Reverse Proxy Setup Guide

This guide walks you through exposing services running on a home Raspberry Pi to the internet using a cheap AWS VPS as a reverse proxy, connected via Tailscale.

## Architecture

```
                        ┌─────────────────────────────────────┐
                        │            Tailscale Network         │
                        │       (Encrypted, No Port Forwarding)│
                        │                                      │
  ┌─────────────┐       │   ┌───────────────┐   ┌───────────────┐
  │  Internet   │──────▶│───│   VPS         │───│   Raspberry Pi │
  │   User      │       │   │ (Caddy Proxy) │   │ (Your Services)│
  │             │       │   │ ~$3/month     │   │                │
  └─────────────┘       │   └───────────────┘   └───────────────┘
                        │     *.pi.junttila.dev                  │
                        └─────────────────────────────────────┘
```

**Benefits:**
- No port forwarding on your home router
- All traffic encrypted via Tailscale
- Automatic HTTPS via Caddy + Let's Encrypt
- VPS cost: ~$3/month (t4g.nano)

---

## Prerequisites

- AWS account with CLI configured
- SSH key pairs for both servers
- Tailscale account with auth keys
- Domain with DNS access (e.g., Squarespace)

---

## Step 1: Set Up the Raspberry Pi (Backend Server)

First, provision the backend server where your services will run.

### 1.1 Generate SSH Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/ansible-lab -C "ansible-lab"
```

### 1.2 Configure Terraform

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

### 1.3 Deploy Infrastructure

```bash
terraform init
terraform apply
```

### 1.4 Provision with Ansible

```bash
# Get a Tailscale auth key from https://login.tailscale.com/admin/settings/keys
./scripts/provision.sh tskey-auth-xxxxx
```

### 1.5 Note the Tailscale IP
TODO script to get this ip
```bash
ssh ubuntu@<pi-public-ip>
tailscale ip -4
# Example: 100.100.100.2
```

---

## Step 2: Set Up the VPS (Reverse Proxy)

### 2.1 Generate SSH Key for VPS

```bash
ssh-keygen -t ed25519 -f ~/.ssh/vps-proxy -C "vps-proxy"
```

### 2.2 Configure Terraform

```bash
cd terraform-vps/
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

### 2.3 Deploy VPS

```bash
terraform init
terraform apply
```

Note the `vps_public_ip` from the output.

### 2.4 Configure Your Sites

Create `ansible/group_vars/vps.yml`:
backend is the tailscale ip of the server

```yaml
caddy_sites:
  - domain: vaultwarden.pi.junttila.dev
    backend: "100.100.100.2:80"
  
  - domain: app.pi.junttila.dev
    backend: "100.100.100.2:3000"
  
  - domain: grafana.pi.junttila.dev
    backend: "100.100.100.2:3001"
```

### 2.5 Provision VPS with Ansible

```bash
./scripts/provision-vps.sh
```
---

## Step 3: Configure DNS

Add A records in your DNS provider pointing each subdomain to the VPS public IP:

| Type | Host | Value |
|------|------|-------|
| A | vaultwarden.pi | `<VPS-PUBLIC-IP>` |
| A | app.pi | `<VPS-PUBLIC-IP>` |
| A | grafana.pi | `<VPS-PUBLIC-IP>` |

---

## Step 4: Verify Setup

```bash
# Test from anywhere
curl -I https://vaultwarden.pi.junttila.dev

# Should return HTTP/2 200 with valid SSL
```

---

## Adding New Services

1. Start your service on the Pi (e.g., on port 8080)

2. Add to `ansible/group_vars/vps.yml`:
   ```yaml
   - domain: newservice.pi.junttila.dev
     backend: "100.100.100.2:8080"
   ```

3. Re-run the playbook:
   ```bash
   ./scripts/provision-vps.sh tskey-auth-xxxxx dummy dummy
   ```

4. Add DNS A record for the new subdomain

---

## Troubleshooting

### Check Tailscale connectivity
```bash
# On VPS
ping 100.100.100.2  # Pi's Tailscale IP
```

### Check Caddy status
```bash
ssh ubuntu@<vps-ip>
sudo systemctl status caddy
sudo journalctl -u caddy -f
```

### Check Caddy config
```bash
cat /etc/caddy/Caddyfile
```

### Test backend directly
```bash
# On VPS, test connection to Pi
curl http://100.100.100.2:80
```

---

## Costs

| Resource | Cost |
|----------|------|
| VPS (t4g.nano) | ~$3/month |
| Pi (existing) | $0 |
| Domain | varies |
| Tailscale | Free tier |

---

## Teardown

```bash
# Destroy VPS
cd terraform-vps/
terraform destroy

# Destroy Pi (if using EC2 for testing)
cd terraform/
terraform destroy
```
