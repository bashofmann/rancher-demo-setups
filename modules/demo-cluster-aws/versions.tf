terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    rancher2 = {
      source = "terraform-providers/rancher2"
    }
  }
  required_version = ">= 0.13"
}
