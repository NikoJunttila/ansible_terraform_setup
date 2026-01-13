terraform is fked, need to apparently have s3 config state.
Use remote state (Better for future)
If you had set up remote state in S3, you could just configure the backend and pull the state. For next time, add this to your Terraform:

for now run ./scripts/provision-vps.sh <actual public_ip>

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
