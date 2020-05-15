resource "azurerm_resource_group" "demo-windows" {
  name     = "${var.prefix}-demo-windows"
  location = var.azure_location
}

resource "azurerm_virtual_network" "demo-windows" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo-windows.location
  resource_group_name = azurerm_resource_group.demo-windows.name
}

resource "azurerm_subnet" "demo-windows-internal" {
  name                 = "${var.prefix}-network-internal"
  resource_group_name  = azurerm_resource_group.demo-windows.name
  virtual_network_name = azurerm_virtual_network.demo-windows.name
  address_prefix       = "10.0.0.0/16"
}