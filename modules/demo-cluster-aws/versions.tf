terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.10.6"
    }
  }
  required_version = ">= 0.13"
}
