terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.17.1"
    }
  }
  required_version = ">= 1.0.0"
}
provider "rancher2" {
  api_url    = var.rancher_url
  insecure   = true
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}