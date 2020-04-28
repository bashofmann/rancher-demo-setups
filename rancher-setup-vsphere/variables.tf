variable "rancher_url" {
  type = string
}
variable "rancher_admin_token" {
  type = string
}

variable "vm_template_name" {
  type = string
}

variable "vcenter_user" {
  type = string
}

variable "vcenter_password" {
  type = string
}

// vCenter server FQDN or IP address
variable "vcenter_server" {
  type = string
}

# vSphere datacenter to use
variable "vsphere_datacenter" {
  type = string
}

# vSphere cluster to use (required unless vsphere_resource_pool is specified)
variable "vsphere_cluster" {
  type    = string
  default = ""
}

# vSphere resource pool to use (required unless vsphere_cluster is specified)
variable "vsphere_resource_pool" {
  type    = string
  default = ""
}

# Name/path of datastore to use
variable "vsphere_datastore" {
  type = string
}

# VM Network to attach the VMs
variable "vsphere_network" {
  type = string
}