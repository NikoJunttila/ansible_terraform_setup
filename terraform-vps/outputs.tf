output "vps_public_ip" {
  description = "Public IP address of the VPS"
  value       = aws_instance.vps.public_ip
}

output "vps_public_dns" {
  description = "Public DNS name of the VPS"
  value       = aws_instance.vps.public_dns
}

output "ssh_command" {
  description = "SSH command to connect to the VPS"
  value       = "ssh ubuntu@${aws_instance.vps.public_ip}"
}

output "next_steps" {
  description = "What to do after provisioning"
  value       = <<-EOF
    
    1. Create Ansible inventory:
       cd ../ansible
       echo "[vps]
       ${aws_instance.vps.public_ip} ansible_user=ubuntu" > inventory/vps.ini
    
    2. Run the VPS proxy playbook:
       ansible-playbook playbooks/vps-proxy.yml -i inventory/vps.ini \
         -e "tailscale_authkey=tskey-xxx" \
         -e "caddy_domain=yourdomain.com" \
         -e "caddy_backend_ip=<pi-tailscale-ip>"
    
    3. Point your domain's DNS A record to: ${aws_instance.vps.public_ip}
  EOF
}
