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
# Please ensure you have run 'ssh-copy-id -i ~/.ssh/ansible-lab ubuntu@pihole' first.
ansible-playbook playbooks/pi.yml \
    -i inventory/pi.ini \
    --ask-vault-pass \
    --extra-vars "tailscale_authkey=$TAILSCALE_KEY" \
    -K

echo "Provisioning complete!"
echo ""
echo "================================================"
echo "Tailscale IPv4 Address:"
ssh -i ~/.ssh/ansible-lab -o StrictHostKeyChecking=no ubuntu@192.168.178.32 "tailscale ip -4"
echo "================================================"
echo ""
echo "Use this IP as 'backend_ip' in ansible/group_vars/vps.yml"
echo ""
