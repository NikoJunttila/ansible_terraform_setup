#!/bin/bash
set -e

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
    -u ubuntu

echo "Provisioning complete!"
