# ARM Ansible Lab
Project template for Ansible and Terraform.

next steps:
figure out how to use tailscale so we can proxy trafic from a VPS to local rasperry
https://tailscale.com/pricing

main goal of this project is to have a selfhosting server that can be accessed from anywhere.
for now the selfhosting server will be a raspberry pi 5 in my home network so i don't want to open ports on my router. and use tailscale to access it from anywhere.



selfhosting list:

pi-hole
vaultwarden
jellyfin
https://github.com/go-shiori/shiori
qbittorrent?



ports problems.

Found the issue! Your security group only allows inbound traffic on ports 22 (SSH), 80 (HTTP), and 443 (HTTPS). Port 8443 is not open, which is why external access fails.

You have two options:

Option 1: Add port 8443 to the security group
I can add an ingress rule for port 8443 in 
security.tf
:

hcl
ingress {
  description = "Custom port 8443"
  from_port   = 8443
  to_port     = 8443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
Then run terraform apply to update the security group.


tldr:
update this /ansible/group_vars/vps.yml
to hold all domains and backends