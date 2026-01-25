# PocketBase Ansible Role

This role installs and manages a PocketBase instance as a systemd service and handles the initial migration of data from a local backup.

## Configuration Variables

The following variables can be customized in `defaults/main.yml` or passed as extra variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `pocketbase_version` | `"0.36.1"` | The version of PocketBase to install. |
| `pocketbase_port` | `8090` | The port PocketBase will listen on (bound to 0.0.0.0). |
| `pocketbase_install_dir` | `"/usr/local/bin"` | Directory where the binary will be installed. |
| `pocketbase_data_dir` | `"/var/lib/pocketbase"` | Base directory for PocketBase data. |
| `pocketbase_user` | `"pocketbase"` | System user to run the service. |
| `pocketbase_group` | `"pocketbase"` | System group to run the service. |
| `pocketbase_local_backup_path` | `"~/backups/pocketbase"` | Local path on your PC containing `pb_data` and `pb_migrations`. |
| `pocketbase_perform_migration` | `false` | Set to `true` to force a sync from your local PC to the server. |

## Data Migration Logic

The role is designed for a **one-time migration** by default:
- It checks if `{{ pocketbase_data_dir }}/pb_data/data.db` exists on the server.
- If it **does not** exist, it will synchronize your local `pb_data` and `pb_migrations` folders to the server.
- If it **does** exist, synchronization is skipped to prevent accidental overwrites of production data.

To force an update from your local machine to the server, run the playbook with:
```bash
ansible-playbook playbooks/deploy_pocketbase.yml -e "pocketbase_perform_migration=true"
```

## Example Playbook

```yaml
- name: Deploy PocketBase
  hosts: vps
  become: yes
  roles:
    - pocketbase
```

## Maintenance

- **Logs**: `journalctl -u pocketbase -f`
- **Service Status**: `systemctl status pocketbase`
- **Restart**: `systemctl restart pocketbase`
