output "windows_ip" {
  value = azurerm_windows_virtual_machine.windows-server.public_ip_address
}
output "linux_ip" {
  value = azurerm_linux_virtual_machine.linux-server.public_ip_address
}