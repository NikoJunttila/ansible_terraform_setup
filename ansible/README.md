# Ansible Lab Setup

This directory contains the Ansible configuration, playbooks, and roles for configuring our ARM64 EC2 lab instance.

## Overview

Ansible is an automation tool that manages servers by running "playbooks" (YAML files) against "inventories" (lists of servers). In this lab, we use Terraform to provision the server and then use Ansible to configure it.

## Directory Structure

- **`ansible.cfg`**: Configuration file. We've set `host_key_checking = False` to make it easier to connect to new cloud instances without manual confirmation.
- **`playbooks/`**: Contains the definition of *what* to run.
    - `hello.yml`: A simple test to verify connectivity.
    - `site.yml`: The main playbook that applies roles to the server.
- **`roles/`**: Reusable units of configuration.
    - `podman/`: Installs Podman container engine.

## Quick Start (Using Scripts)

We have provided helper scripts in the `scripts/` directory (at the project root) to make running Ansible easier by automatically fetching the IP address from Terraform.

### 1. Test Connectivity
To verify you can reach the server:
```bash
../scripts/test_connection.sh
```
This runs the `playbooks/hello.yml` playbook.

### 2. Provision the Server
To install all configured software (like Podman):
```bash
../scripts/provision.sh
```
This runs the `playbooks/site.yml` playbook.

## Manual Usage

If you prefer to run `ansible-playbook` manually, you need the public IP of your instance (get it from `terraform output public_ip`).

Run a playbook against the specific IP:
```bash
# Replace x.x.x.x with your instance IP
ansible-playbook playbooks/site.yml -i "x.x.x.x," -u ubuntu --private-key ~/.ssh/ansible-lab
```
**Note:** The trailing comma in `"x.x.x.x,"` is important! It tells Ansible that this is a list of hosts, not a file path.

## Adding New Roles

1.  Create a new folder in `roles/` (e.g., `roles/my_app`).
2.  Create `roles/my_app/tasks/main.yml` and define your tasks.
3.  Add the role to `playbooks/site.yml`.
4.  Run `../scripts/provision.sh` to apply changes.
