variable "digitalocean_token" {
  type = string
}
variable "rancher_url" {
  type = string
}
variable "rancher_access_key" {
  type = string
}
variable "rancher_secret_key" {
  type = string
}
variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "bhofmann"
}
variable "docker_version" {
  type        = string
  description = "Docker version to install on nodes"
  default     = "19.03"
}
variable "ssh_key_file_name" {
  type        = string
  description = "File path and name of SSH private key used for infrastructure and RKE"
  default     = "~/.ssh/id_rsa"
}