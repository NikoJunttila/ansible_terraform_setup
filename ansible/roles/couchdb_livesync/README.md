# CouchDB for Obsidian LiveSync

This Ansible role sets up a CouchDB instance optimized for the [Obsidian livesync](https://github.com/vrtmrz/obsidian-livesync) plugin using Podman.

## Features

- **Podman Integration**: Runs as a rootless or root container with automatic systemd service generation.
- **Automated Setup**: Automatically handles single-node cluster initialization.
- **Pre-configured**: Sets up CORS, authentication requirements, and max document sizes as required by the plugin.
- **Idempotent**: Safely re-runs without overwriting data or failing on existing databases.

## Variable Configuration

> [!IMPORTANT]
> Use `ansible-vault` to encrypt your `couchdb_password`.

## Usage

1.  **Deploy**:
    ```bash
    ansible-playbook -i inventory/inventory.ini playbooks/obsidian_sync.yml
    ```

2.  **Reverse Proxy (Caddy)**:
    Add this to your `Caddyfile`:
    ```caddy
    sync.example.com {
        reverse_proxy localhost:5984
    }
    ```

3.  **Obsidian Plugin Setup**:
    - **CouchDB URL**: `https://sync.example.com` (or `http://<ip>:5984` if local)
    - **Username**: Your `couchdb_user`
    - **Password**: Your `couchdb_password`
    - **Database**: Your `couchdb_database_name`
    - **Setup Mode**: `LiveSync`

## Health Check
Verify the service is running:
```bash
curl http://localhost:5984/_up
```
Expected response: `{"status":"ok"}`
