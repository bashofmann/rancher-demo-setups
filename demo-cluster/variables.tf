variable "output_dir" {
  type = string
}
variable "rancher_url" {
  type = string
}
variable "rancher_admin_token" {
  type = string
}
variable "rke_kubernetes_version" {
  type = string
}
variable "controlplane-nodetemplate-id" {
}
variable "worker-nodetemplate-id" {
}
variable "prefix" {
  type    = string
  default = "bhofmann"
}