output "rancher_url" {
  value = "https://${digitalocean_record.rancher.fqdn}"
}

output "rke_template" {
  value = local_file.rke_configuration.content
}

output "kube_admin" {
  value = data.local_file.kube_admin.content
}

output "rke_state" {
  value = data.local_file.rke_state.content
}