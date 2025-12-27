# Tailscale Funnel Quick Start

This guide explains how to set up Tailscale Funnel on your EC2 instance using Ansible.

## Prerequisites

1. A [Tailscale account](https://tailscale.com/) (free tier is fine).
2. An EC2 instance provisioned with Terraform (`terraform apply`).

---

## Step 1: Generate an Auth Key

1. Go to the [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys).
2. Click **"Generate auth key..."**.
3. Configure:
   - **Reusable:** Check this if you want to use the same key for multiple machines.
   - **Ephemeral:** Check this if you want the node to be removed automatically when it disconnects.
   - **Pre-approved:** Check this to avoid manually approving the node.
4. Click **"Generate key"**.
5. **Copy the key** (it starts with `tskey-auth-...`). You won't see it again!

---

## Step 2: Run Provisioning with the Auth Key

You need to pass the auth key to Ansible when running the playbook.

### Option A: Direct Ansible Command

```bash
# Get the IP from Terraform
cd terraform && IP=$(terraform output -raw public_ip) && cd ..

# Run with auth key
cd ansible
ansible-playbook playbooks/site.yml \
    -i "$IP," \
    --private-key ~/.ssh/ansible-lab \
    -u ubuntu \
    --extra-vars "tailscale_authkey=tskey-auth-YOUR_KEY_HERE"
```

### Option B: Modify provision.sh

Add the auth key as an environment variable or argument to `scripts/provision.sh`:

```bash
# Example: ./scripts/provision.sh tskey-auth-YOUR_KEY_HERE
TAILSCALE_KEY="${1:-}"  # First argument

ansible-playbook playbooks/site.yml \
    -i "$IP," \
    ... \
    --extra-vars "tailscale_authkey=$TAILSCALE_KEY"
```

---

## Step 3: Verify Tailscale is Running

SSH into your instance and check:

```bash
ssh -i ~/.ssh/ansible-lab ubuntu@<IP>
tailscale status
```

You should see your machine listed in the Tailscale network.

---

## Step 4: Enable Funnel (Manual)

Once Tailscale is running, enable Funnel to expose Vaultwarden (port 80):

```bash
# On the EC2 instance:
sudo tailscale funnel 80
```

Tailscale will print a public URL like:
```
https://yournode.tailnet-name.ts.net
```

Share this URL to access Vaultwarden from anywhere!

---

## Notes

- **Funnel Ports:** Only 443, 8443, and 10000 are supported for Funnel.
- **Funnel Beta:** Funnel is in beta but stable for everyday use.
- **Bandwidth:** Funnel has bandwidth limits on the free tier.
