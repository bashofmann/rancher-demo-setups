resource "azurerm_resource_group" "demo-rancher" {
  name     = "${var.prefix}-demo-rancher"
  location = var.azure_location
}

resource "azurerm_virtual_network" "demo-rancher" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.demo-rancher.location
  resource_group_name = azurerm_resource_group.demo-rancher.name
}

resource "azurerm_subnet" "demo-rancher-internal" {
  name                 = "${var.prefix}-network-internal"
  resource_group_name  = azurerm_resource_group.demo-rancher.name
  virtual_network_name = azurerm_virtual_network.demo-rancher.name
  address_prefixes     = ["10.0.0.0/16"]
}