variable "rancher_url" {
  type = string
}
variable "rancher_admin_token" {
  type    = string
  default = null
}
variable "rancher_access_key" {
  type    = string
  default = null
}
variable "rancher_secret_key" {
  type    = string
  default = null
}
variable "cluster_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_kubeconfig" {
  type = string
}
variable "controlplane-nodetemplate-id" {
  type = string
}
variable "worker-nodetemplate-id" {
  type = string
}
variable "prefix" {
  type    = string
  default = "bhofmann"
}