output "server_ipv4" {
  description = "The public IPv4 address of the server"
  value       = hcloud_server.web.ipv4_address
}

output "server_ipv6" {
  description = "The public IPv6 address of the server"
  value       = hcloud_server.web.ipv6_address
}
