terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.13.0-bh"
    }
  }
  required_version = ">= 0.13"
}
provider "rancher2" {
  api_url    = var.rancher_url
  insecure   = true
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}