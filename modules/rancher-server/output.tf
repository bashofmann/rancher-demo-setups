output "rancher_admin_token" {
  value = rancher2_bootstrap.admin.token
}

output "rancher_url" {
  value = "https://${digitalocean_record.rancher.fqdn}"
}