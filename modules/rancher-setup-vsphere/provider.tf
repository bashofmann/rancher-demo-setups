# Rancher2 administration provider
provider "rancher2" {
  version   = "~> 1.7"
  api_url   = var.rancher_url
  insecure  = true
  token_key = var.rancher_admin_token
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
}