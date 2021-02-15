terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.10.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.0.2"
    }
  }
  required_version = ">= 0.13"
}
provider "rancher2" {
  api_url    = var.rancher_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}
provider "kubernetes" {
  config_path = local_file.kube_config.filename
}