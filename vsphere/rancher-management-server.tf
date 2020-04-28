module "rancher-server" {
  source = "../rancher-server"

  nodes                  = vsphere_virtual_machine.rancher_server
  dns_record_type        = "A"
  dns_record_value       = vsphere_virtual_machine.rancher_server[0].default_ip_address
  output_dir             = abspath("${path.module}/out")
  email                  = var.email
  rancher_admin_password = var.rancher_admin_password
  rancher_subdomain      = var.rancher_subdomain
  digitalocean_token     = var.digitalocean_token
}

module "rancher-setup" {
  source                = "../rancher-setup-vsphere"
  rancher_url           = module.rancher-server.rancher_url
  rancher_admin_token   = module.rancher-server.rancher_admin_token
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