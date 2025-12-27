#!/bin/bash
set -e

# Go to terraform directory to get outputs
cd "$(dirname "$0")/../terraform"

# Get Public IP
IP=$(terraform output -raw public_ip)
KEY_NAME=$(terraform output -raw key_name 2>/dev/null || echo "ansible-lab-key") 

# We assume the private key is at the default location for now as per README instructions
PRIVATE_KEY_PATH="$HOME/.ssh/ansible-lab"

if [ -z "$IP" ]; then
    echo "Error: Could not get IP from Terraform. Is the infrastructure up?"
    exit 1
fi

echo "Testing connection to $IP..."

# Go back to ansible directory
cd ../ansible

# Run simple ping playbook
# We use comma after IP to tell Ansible this is a list of hosts, not a file path
ansible-playbook playbooks/hello.yml \
    -i "$IP," \
    --private-key "$PRIVATE_KEY_PATH" \
    -u ubuntu

echo "Done!"
