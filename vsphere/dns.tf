data "digitalocean_domain" "rancher" {
  name = var.rancher_domain
}

// todo add lb
resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.rancher.name
  type   = "A"
  name   = var.rancher_subdomain
  value  = vsphere_virtual_machine.rancher_server[0].default_ip_address
  ttl    = 60
}
