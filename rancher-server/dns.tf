data "digitalocean_domain" "rancher" {
  name = var.rancher_domain
}

resource "digitalocean_record" "rancher" {
  domain = data.digitalocean_domain.rancher.name
  type   = var.dns_record_type
  name   = var.rancher_subdomain
  value  = var.dns_record_value
  ttl    = 60
}
