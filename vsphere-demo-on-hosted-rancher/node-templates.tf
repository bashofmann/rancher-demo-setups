module "rancher-setup" {
  source                = "../modules/rancher-setup-vsphere"
  rancher_url           = var.rancher_url
  rancher_access_key    = var.rancher_access_key
  rancher_secret_key    = var.rancher_secret_key
  vm_template_name      = var.vm_template_name
  vsphere_datacenter    = var.vsphere_datacenter
  vsphere_cluster       = var.vsphere_cluster
  vsphere_resource_pool = var.vsphere_resource_pool
  vsphere_datastore     = var.vsphere_datastore
  vsphere_network       = var.vsphere_network
  vcenter_server        = var.vcenter_server
  vcenter_user          = var.vcenter_user
  vcenter_password      = var.vcenter_password
}