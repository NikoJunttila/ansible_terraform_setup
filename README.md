# ARM Ansible Lab
Project template for Ansible and Terraform.

main goal of this project is to have a selfhosting server that can be accessed from anywhere.
for now the selfhosting server will be a raspberry pi 5 in my home network so i don't want to open ports on my router. and use tailscale to access it from anywhere.




## Raspberry Pi Local Setup

Follow these steps to configure your Raspberry Pi 5 for this playbook.

### 1. OS Installation
1.  Download **Raspberry Pi Imager**.
2.  Choose OS: **Raspberry Pi OS (64-bit)** (Lite is recommended for servers).
3.  Choose Storage: Your SD card / NVMe drive.
4.  **Settings (Gear Icon)**:
    -   **Set Hostname**: `raspberrypi` (or your preferred name).
    -   **Enable SSH**: Use password authentication (we will switch to keys later).
    -   **Set usage**: username `pi`.
    -   **Configure Wireless LAN**: If using Wi-Fi (Server is recommended on Ethernet).
5.  Write the image.

### 2. Connect to the Pi
1.  Boot the Pi and connect it to your network.
2.  Find its IP address (check your router's DHCP list).
3.  Copy your SSH key to the Pi for passwordless access:
    ```bash
    ssh-copy-id -i ~/.ssh/ansible-lab.pub pi@<RASPBERRY_PI_IP>
    ```

### 3. Configure Ansible Inventory
Create a new inventory file `ansible/inventory/pi.ini`:

```ini
[pi]
<RASPBERRY_PI_IP> ansible_user=pi ansible_ssh_private_key_file=~/.ssh/id_rsa verify_host_key_dns=no
```
*(Replace `<RASPBERRY_PI_IP>` with the actual IP address).*

### 4. Run the Playbook
Run the Ansible playbook to provision the Pi:

```bash
cd ansible
ansible-playbook -i inventory/pi.ini playbooks/site.yml --ask-become-pass
```
-   `--ask-become-pass`: Prompts for the `sudo` password (the one you set in step 1).

### Troubleshooting
-   **SSH Access**: Ensure you can `ssh pi@<IP>` without a password before running Ansible.
-   **Python**: Ansible requires Python on the target. Raspberry Pi OS comes with it by default.
