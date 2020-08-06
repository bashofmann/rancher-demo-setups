provider "azurerm" {
  version = "2.0.0"
  features {}

  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

provider "rancher2" {
  version    = "1.10.0"
  api_url    = var.rancher_url
  insecure   = true
  token_key  = var.rancher_admin_token
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}