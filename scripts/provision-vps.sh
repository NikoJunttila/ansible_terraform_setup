#!/bin/bash
set -e

# Provisions the VPS as a reverse proxy using Ansible
#
# Sites are configured in: ansible/group_vars/vps.yml
# Backend IPs should be Tailscale IPs (100.x.x.x), not public IPs
#
#   ./provision-vps.sh <ip_address>
#   ./provision-vps.sh <tailscale_authkey> [ip_address]
#   TAILSCALE_AUTHKEY=<key> ./provision-vps.sh [ip_address]

ARG1="$1"
ARG2="$2"
IP=""
TAILSCALE_KEY="${TAILSCALE_AUTHKEY}"

# Check if first argument is an IP address
if [[ "$ARG1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    IP="$ARG1"
elif [ -n "$ARG1" ]; then
    TAILSCALE_KEY="$ARG1"
    # Check if second argument is an IP address
    if [[ "$ARG2" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IP="$ARG2"
    fi
fi

if [ -z "$TAILSCALE_KEY" ]; then
    echo "Error: Tailscale auth key is required."
    echo ""
    echo "Usage: $0 <tailscale_authkey> [ip]"
    echo "   or: TAILSCALE_AUTHKEY=<key> $0 [ip]"
    echo "   or: TAILSCALE_AUTHKEY=<key> $0 <ip>"
    echo ""
    echo "Get a key from: https://login.tailscale.com/admin/settings/keys"
    exit 1
fi

# Get absolute path to project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Go to terraform-vps directory to get outputs
cd "$PROJECT_ROOT/terraform-vps"

# Get Public IP from Terraform if not provided
if [ -z "$IP" ]; then
    IP=$(terraform output -raw vps_public_ip 2>/dev/null || echo "")
fi

if [ -z "$IP" ]; then
    echo "Error: Could not get IP from Terraform. Is the VPS infrastructure up?"
    echo "Run 'terraform apply' in terraform-vps/ first."
    exit 1
fi

# Private key path
PRIVATE_KEY_PATH="${VPS_SSH_KEY:-$HOME/.ssh/vps-proxy}"

if [ ! -f "$PRIVATE_KEY_PATH" ]; then
    echo "Error: SSH private key not found at $PRIVATE_KEY_PATH"
    echo "Set VPS_SSH_KEY environment variable to specify a different path."
    exit 1
fi

# Check if sites config exists
SITES_CONFIG="$PROJECT_ROOT/ansible/group_vars/vps.yml"
if [ ! -f "$SITES_CONFIG" ]; then
    echo "Warning: $SITES_CONFIG not found."
    echo "Copy the example and configure your sites:"
    echo "  cp ansible/group_vars/vps.yml.example ansible/group_vars/vps.yml"
    echo ""
fi

echo "================================================"
echo "Provisioning VPS Reverse Proxy"
echo "================================================"
echo "VPS IP:      $IP"
echo "SSH Key:     $PRIVATE_KEY_PATH"
echo "Sites:       $SITES_CONFIG"
echo "================================================"
echo ""

# Go to ansible directory
cd "$PROJECT_ROOT/ansible"

# Run VPS proxy playbook
ansible-playbook playbooks/vps-proxy.yml \
    -i "$IP," \
    --private-key "$PRIVATE_KEY_PATH" \
    -u ubuntu \
    -e @group_vars/vps.yml \
    --extra-vars "tailscale_authkey=$TAILSCALE_KEY"

echo ""
echo "================================================"
echo "VPS Provisioning Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Point your domain's DNS A records to: $IP"
echo "  2. Wait for DNS propagation (may take a few minutes)"
echo ""

# Extract and display configured domains
if [ -f "$SITES_CONFIG" ]; then
    echo "  3. Test your sites:"
    grep -E "^\s*-?\s*domain:" "$SITES_CONFIG" | sed 's/.*domain:\s*["]*\([^"]*\).*/     curl -I https:\/\/\1/' | head -10
fi
echo ""
