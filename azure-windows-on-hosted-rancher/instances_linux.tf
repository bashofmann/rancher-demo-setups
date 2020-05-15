resource "azurerm_public_ip" "linux-server-pip" {
  name                = "${var.prefix}-linux-server-pip"
  location            = azurerm_resource_group.demo-windows.location
  resource_group_name = azurerm_resource_group.demo-windows.name
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface" "linux-server-interface" {
  name                = "${var.prefix}-linux-server-interface"
  location            = azurerm_resource_group.demo-windows.location
  resource_group_name = azurerm_resource_group.demo-windows.name

  ip_configuration {
    name                          = "${var.prefix}_linux-server_ip_config"
    subnet_id                     = azurerm_subnet.demo-windows-internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.linux-server-pip.id
  }
}

resource "azurerm_linux_virtual_machine" "linux-server" {
  name                  = "${var.prefix}-linux"
  location              = azurerm_resource_group.demo-windows.location
  resource_group_name   = azurerm_resource_group.demo-windows.name
  network_interface_ids = [azurerm_network_interface.linux-server-interface.id]
  size                  = "Standard_B2MS"
  admin_username        = "ubuntu"

  custom_data = base64encode(templatefile("../userdata/server.sh", {
    docker_version   = var.docker_version
    username         = "ubuntu"
    register_command = ""
  }))

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("${var.ssh_key_file_name}.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }
}