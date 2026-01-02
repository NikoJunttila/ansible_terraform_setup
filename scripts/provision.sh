#!/bin/bash
set -e

# Tailscale auth key: use command line argument if provided, otherwise check environment variable
TAILSCALE_KEY="${1:-$TAILSCALE_AUTHKEY}"

if [ -z "$TAILSCALE_KEY" ]; then
    echo "Error: Tailscale auth key is required."
    echo "Usage: $0 <tailscale_authkey>"
    echo "   or: TAILSCALE_AUTHKEY=<key> $0"
    exit 1
fi

# Go to terraform directory to get outputs
cd "$(dirname "$0")/../terraform"

# Get Public IP
IP=$(terraform output -raw public_ip)
# We assume the private key is at the default location
PRIVATE_KEY_PATH="$HOME/.ssh/ansible-lab"

if [ -z "$IP" ]; then
    echo "Error: Could not get IP from Terraform. Is the infrastructure up?"
    exit 1
fi

echo "Provisioning $IP..."

# Go back to ansible directory
cd ../ansible

# Run site playbook
ansible-playbook playbooks/site.yml \
    -i "$IP," \
    --private-key "$PRIVATE_KEY_PATH" \
    -u ubuntu \
    --extra-vars "tailscale_authkey=$TAILSCALE_KEY"

echo "Provisioning complete!"
echo ""
echo "================================================"
echo "Tailscale IPv4 Address:"
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@"$IP" "tailscale ip -4"
echo "================================================"
echo ""
echo "Use this IP as 'backend_ip' in ansible/group_vars/vps.yml"
echo ""
