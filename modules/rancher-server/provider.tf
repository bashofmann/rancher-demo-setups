provider "digitalocean" {
  token = var.digitalocean_token
}

# Rancher2 bootstrapping provider
provider "rancher2" {
  api_url   = "https://${digitalocean_record.rancher.fqdn}"
  insecure  = true
  bootstrap = true
}
