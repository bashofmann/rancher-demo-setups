variable "digitalocean_token" {
  type = string
}
variable "dns_record_type" {
  type    = string
  default = "A"
}
variable "dns_record_value" {
  type = string
}
variable "rancher_domain" {
  type    = string
  default = "plgrnd.be"
}
variable "rancher_subdomain" {
  type = string
}
variable "nodes" {
}
variable "rke_kubernetes_version" {
  type    = string
  default = "v1.18.6-rancher1-1"
}
variable "output_dir" {
  type = string
}
variable "cert_manager_version" {
  type    = string
  default = "v0.15.2"
}
variable "rancher_version" {
  type    = string
  default = "2.4.5"
}
variable "email" {
  type = string
}
variable "rancher_admin_password" {
  type = string
}