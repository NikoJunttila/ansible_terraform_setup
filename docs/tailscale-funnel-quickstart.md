# Tailscale Funnel Quick Start

This guide explains how to set up Tailscale Funnel on your Raspberry Pi using Ansible.

## Prerequisites

1. A [Tailscale account](https://tailscale.com/) (free tier is fine).
2. A Raspberry Pi reachable over SSH and listed in `ansible/inventory/inventory.ini` (see the root `README.md`).

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
cd ansible
ansible-playbook playbooks/pi.yml \
    --tags tailscale \
    --ask-vault-pass \
    -K \
    --extra-vars "tailscale_authkey=tskey-auth-YOUR_KEY_HERE"
```

### Option B: Provisioning Script

```bash
./scripts/provision-pi.sh tskey-auth-YOUR_KEY_HERE
# or
TAILSCALE_AUTHKEY=tskey-auth-YOUR_KEY_HERE ./scripts/provision-pi.sh
```

---

## Step 3: Verify Tailscale is Running

SSH into your Pi and check:

```bash
ssh derp@<pi-local-ip>
tailscale status
```

You should see your machine listed in the Tailscale network.

---

## Step 4: Enable Funnel (Manual)

Once Tailscale is running, enable Funnel to expose Vaultwarden (port 80):

```bash
# On the Pi:
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
