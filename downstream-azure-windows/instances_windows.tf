resource "azurerm_public_ip" "windows-server-pip" {
  name                = "${var.prefix}-windows-server-pip"
  location            = azurerm_resource_group.demo-windows.location
  resource_group_name = azurerm_resource_group.demo-windows.name
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "windows-server-interface" {
  name                = "${var.prefix}-windows-server-interface"
  location            = azurerm_resource_group.demo-windows.location
  resource_group_name = azurerm_resource_group.demo-windows.name

  ip_configuration {
    name                          = "${var.prefix}_windows-server_ip_config"
    subnet_id                     = azurerm_subnet.demo-windows-internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-server-pip.id
  }
}
resource "azurerm_windows_virtual_machine" "windows-server" {
  name                = "${var.prefix}-win"
  resource_group_name = azurerm_resource_group.demo-windows.name
  location            = azurerm_resource_group.demo-windows.location
  size                = "Standard_B2MS"
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.windows-server-interface.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-with-Containers"
    version   = "latest"
  }
}