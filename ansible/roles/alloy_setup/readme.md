getting logs from journal was hard.

check that app actually sends logs there with correct container name using:

journalctl CONTAINER_NAME=systemd-translations-helper | tail -50
