provider "vsphere" {
  version              = "~> 1.17"
  user                 = var.vcenter_user
  password             = var.vcenter_password
  vsphere_server       = var.vcenter_server
  allow_unverified_ssl = var.vcenter_insecure
}
