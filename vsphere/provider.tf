provider "vsphere" {
  version        = "~> 1.17"
  user           = var.vcenter_user
  password       = var.vcenter_password
  vsphere_server = var.vcenter_server
  allow_unverified_ssl = var.vcenter_insecure
}

provider "digitalocean" {
  version = "~> 1.15"
  token = var.digitalocean_token
}

# Rancher2 bootstrapping provider
provider "rancher2" {
  version = "~> 1.7"

  alias = "bootstrap"

  api_url  = "https://${digitalocean_record.rancher.fqdn}"
  insecure = true
  bootstrap = true
}
