variable "prefix" {
  type        = string
  description = "Prefix added to names of all resources"
  default     = "bhofmann"
}
variable "vcenter_user" {
  type = string
}
variable "vcenter_password" {
  type = string
}
variable "vcenter_server" {
  type = string
}
variable "ssh_key_file_name" {
  type        = string
  description = "File path and name of SSH private key used for infrastructure and RKE"
  default     = "~/.ssh/id_rsa"
}
variable "vm_template_name" {
  type = string
}
variable "vsphere_datacenter" {
  type = string
}
variable "vsphere_cluster" {
  type    = string
  default = ""
}
variable "vsphere_resource_pool" {
  type    = string
  default = ""
}
variable "vsphere_datastore" {
  type = string
}
variable "vsphere_network" {
  type = string
}