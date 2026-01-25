output "server_ipv4" {
  description = "The public IPv4 address of the server"
  value       = hcloud_server.web.ipv4_address
}

# output "server_ipv6" {
#   description = "The public IPv6 address of the server"
#   value       = hcloud_server.web.ipv6_address
# }

output "ssh_connection" {
  description = "SSH command to connect to the server"
  value       = "ssh -i ~/.ssh/hcloud-key ${var.ssh_user}@${hcloud_server.web.ipv4_address}"
}
