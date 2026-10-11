# Ansible Setup

This directory contains the Ansible configuration, playbooks, and roles for configuring the home Raspberry Pi (backend services) and the Hetzner VPS (Caddy reverse proxy).

## Overview

Ansible is an automation tool that manages servers by running "playbooks" (YAML files) against "inventories" (lists of servers). The VPS is provisioned with Terraform (`terraform-hetzner/`) and then configured with Ansible; the Pi is set up by hand and configured with Ansible.

## Directory Structure

- **`ansible.cfg`**: Configuration file. We've set `host_key_checking = False` to make it easier to connect to new cloud instances without manual confirmation.
- **`inventory/`**: Hosts (`inventory.ini`) and group variables (`group_vars/`) for the `pi` and `vps` groups.
- **`playbooks/`**: Contains the definition of *what* to run.
    - `pi.yml`: Applies the service roles to the Raspberry Pi.
    - `vps-proxy.yml`: Configures the VPS as a Caddy reverse proxy.
- **`roles/`**: Reusable units of configuration (Podman, Tailscale, Caddy, monitoring, and the individual services).

## Quick Start (Using Scripts)

Helper scripts live in the `scripts/` directory (at the project root).

### 1. Provision the Pi
```bash
../scripts/provision-pi.sh tskey-auth-xxxxx
```
This runs the `playbooks/pi.yml` playbook.

### 2. Provision the VPS
```bash
../scripts/provision-vps.sh tskey-auth-xxxxx
```
This runs the `playbooks/vps-proxy.yml` playbook. The VPS IP is read from `terraform output server_ipv4` in `terraform-hetzner/` unless you pass it as an argument.

## Manual Usage

Run a playbook against the inventory, optionally limited to specific roles with tags:
```bash
ansible-playbook playbooks/pi.yml --ask-vault-pass -K
ansible-playbook playbooks/pi.yml --tags "monitoring,grafana" --ask-vault-pass -K
```

## Adding New Roles

1.  Create a new folder in `roles/` (e.g., `roles/my_app`).
2.  Create `roles/my_app/tasks/main.yml` and define your tasks.
3.  Add the role to `playbooks/pi.yml` (with a tag).
4.  Run `ansible-playbook playbooks/pi.yml --tags my_app` to apply changes.
