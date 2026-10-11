#!/bin/bash
set -e

# Tailscale auth key: use command line argument if provided, otherwise check environment variable
TAILSCALE_KEY="${1:-$TAILSCALE_AUTHKEY}"

if [ -z "$TAILSCALE_KEY" ]; then
    echo "Error: Tailscale auth key is not set. Tailscale setup might fail or be skipped."
    echo "Usage: $0 <tailscale_authkey>"
    echo "   or: TAILSCALE_AUTHKEY=<key> $0"
    exit 1
fi

echo "Provisioning local Raspberry Pi (pihole)..."

# Go to ansible directory
cd "$(dirname "$0")/../ansible"

# Run site playbook
# Host, SSH user and key come from the [pi] group in the inventory
ansible-playbook playbooks/pi.yml \
    -i inventory/inventory.ini \
    --ask-vault-pass \
    --extra-vars "tailscale_authkey=$TAILSCALE_KEY" \
    -K

echo "Provisioning complete!"
echo ""
echo "================================================"
echo "Tailscale IPv4 Address:"
ansible pi -i inventory/inventory.ini -m command -a "tailscale ip -4" -o
echo "================================================"
echo ""
echo "Use this IP as 'backend_ip' in ansible/inventory/group_vars/vps.yml"
echo ""
