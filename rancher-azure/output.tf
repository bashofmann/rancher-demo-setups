output "node_ips" {
  value = [
    azurerm_linux_virtual_machine.linux-server.public_ip_address
  ]
}