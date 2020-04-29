variable "rancher_url" {
  type = string
}
variable "rancher_admin_token" {
  type = string
  default = null
}
variable "rancher_access_key" {
  type = string
  default = null
}
variable "rancher_secret_key" {
  type = string
  default = null
}

variable "prefix" {
  type    = string
  default = "bhofmann"
}
variable "rke_kubernetes_version" {
  type = string
}
variable "output_dir" {
  type = string
}