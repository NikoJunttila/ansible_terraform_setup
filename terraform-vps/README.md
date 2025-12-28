# VPS Reverse Proxy - Terraform

This Terraform configuration creates a minimal AWS EC2 instance to act as a public-facing reverse proxy for your home Raspberry Pi via Tailscale.

> **Note:** This only provisions the infrastructure. Use the Ansible playbook to configure Tailscale and Caddy.

## Cost

- **t4g.nano**: ~$3/month (0.5 vCPU, 0.5GB RAM) - ARM-based, cheapest option
- **t3.micro**: ~$8/month (2 vCPU, 1GB RAM) - x86-based, free tier eligible

## Prerequisites

1. AWS CLI configured with credentials
2. SSH key pair for VPS access

```bash
# Generate SSH key (if needed)
ssh-keygen -t ed25519 -f ~/.ssh/vps-proxy -C "vps-proxy"
```

## Quick Start

```bash
# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# 2. Deploy
terraform init
terraform plan
terraform apply

# 3. Note the public IP from output
```

## After Deployment

Use Ansible to configure the VPS:

```bash
cd ../ansible

# Create inventory with VPS IP
echo "[vps]
<vps-public-ip> ansible_user=ubuntu" > inventory/vps.ini

# Run playbook
ansible-playbook playbooks/vps-proxy.yml -i inventory/vps.ini \
  -e "tailscale_authkey=tskey-xxx" \
  -e "caddy_domain=example.com" \
  -e "caddy_backend_ip=100.x.x.x"
```

## Teardown

```bash
terraform destroy
```
