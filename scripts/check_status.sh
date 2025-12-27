#!/bin/bash
set -e

# Go to terraform directory to get outputs
cd "$(dirname "$0")/../terraform"

# Get Public IP from argument or Terraform
if [ -n "$1" ]; then
    IP="$1"
else
    IP=$(terraform output -raw public_ip 2>/dev/null)
fi

PRIVATE_KEY_PATH="$HOME/.ssh/ansible-lab"

if [ -z "$IP" ]; then
    echo "Error: Could not get IP from Terraform and no IP argument provided."
    echo "Usage: ./check_status.sh [IP_ADDRESS]"
    exit 1
fi

echo "Checking status on $IP..."

# Check Systemd Status
echo "--- Systemd Status ---"
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$IP "sudo systemctl status vaultwarden --no-pager -l" || echo "Systemd check failed"

echo -e "\n--- Journal Logs (Last 50 lines) ---"
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$IP "sudo journalctl -u vaultwarden.service -n 50 --no-pager" || echo "Journal check failed"

echo -e "\n--- Root Podman Containers ---"
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$IP "sudo podman ps -a" || echo "Podman check failed"

echo -e "\n--- HTTP Check (Localhost) ---"
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$IP "curl -v http://localhost:80" || echo "HTTP check failed"
