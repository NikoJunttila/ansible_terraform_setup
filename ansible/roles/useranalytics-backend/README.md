# UserAnalytics Backend Role

This role deploys the userAnalytics backend application using podman.

## Configuration

### Default Variables
Located in `defaults/main.yml`:
- `useranalytics_backend_repo`: GitHub repository URL
- `useranalytics_backend_dest`: Destination directory on the host
- `useranalytics_backend_port`: Port the backend will listen on (default: 8000)
- `useranalytics_backend_version`: Git branch/tag to deploy (default: main)

### Sensitive Variables
Located in `vars/vault.yml` (should be encrypted):
- `useranalytics_backend_db_url`: Database connection string (Turso libSQL or local SQLite)
- `useranalytics_backend_email_code`: SMTP email app password/secret

## Setup Instructions

1. **Encrypt the vault file** with your actual credentials:
   ```bash
   # Edit the vault file with your actual values
   ansible-vault edit ansible/roles/useranalytics-backend/vars/vault.yml
   ```

2. **Update the values** in the vault:
   - Set `useranalytics_backend_db_url` to your Turso database URL with auth token
   - Set `useranalytics_backend_email_code` to your SMTP app password

3. **Run the playbook** with vault password:
   ```bash
   ansible-playbook -i ansible/inventory/pi.ini ansible/playbooks/pi.yml --ask-vault-pass
   ```

## What This Role Does

1. Loads encrypted vault variables
2. Ensures git is installed
3. Clones the userAnalytics repository
4. Creates a `.env` file with environment variables from the vault
5. Builds a podman image from the Dockerfile
6. Runs the container with the environment variables

## Environment Variables

The role creates an `.env` file with:
- `PORT`: HTTP server port (from defaults)
- `DB_URL`: Database connection string (from vault)
- `emailCode`: SMTP email secret (from vault)
