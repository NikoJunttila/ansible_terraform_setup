#!/bin/bash
set -e

# Destroys both Terraform setups (VPS and Pi/EC2)
#
# Usage:
#   ./destroy.sh          # Destroy both
#   ./destroy.sh vps      # Destroy VPS only
#   ./destroy.sh pi       # Destroy Pi/EC2 only

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET="${1:-all}"

destroy_vps() {
    echo "================================================"
    echo "Destroying VPS (terraform-vps)"
    echo "================================================"
    
    if [ -d "$PROJECT_ROOT/terraform-vps" ] && [ -f "$PROJECT_ROOT/terraform-vps/terraform.tfstate" ]; then
        cd "$PROJECT_ROOT/terraform-vps"
        terraform destroy -auto-approve
        echo "VPS destroyed."
    else
        echo "No VPS infrastructure found (terraform-vps/terraform.tfstate missing)"
    fi
}

destroy_pi() {
    echo "================================================"
    echo "Destroying Pi/EC2 (terraform)"
    echo "================================================"
    
    if [ -d "$PROJECT_ROOT/terraform" ] && [ -f "$PROJECT_ROOT/terraform/terraform.tfstate" ]; then
        cd "$PROJECT_ROOT/terraform"
        terraform destroy -auto-approve
        echo "Pi/EC2 destroyed."
    else
        echo "No Pi/EC2 infrastructure found (terraform/terraform.tfstate missing)"
    fi
}

case "$TARGET" in
    vps)
        destroy_vps
        ;;
    pi)
        destroy_pi
        ;;
    all)
        destroy_vps
        echo ""
        destroy_pi
        ;;
    *)
        echo "Unknown target: $TARGET"
        echo "Usage: $0 [vps|pi|all]"
        exit 1
        ;;
esac

echo ""
echo "================================================"
echo "Destroy complete!"
echo "================================================"
