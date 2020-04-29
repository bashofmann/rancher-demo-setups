resource "rancher2_cloud_credential" "vcenter" {
  name = "vcenter"

  vsphere_credential_config {
    vcenter  = var.vcenter_server
    username = var.vcenter_user
    password = var.vcenter_password
  }
}

resource "rancher2_node_template" "controlplane" {
  name        = "controlplane"
  description = "Template for control plane nodes"

  cloud_credential_id = rancher2_cloud_credential.vcenter.id

  vsphere_config {
    clone_from    = var.vm_template_name
    creation_type = "template"
    datacenter    = var.vsphere_datacenter
    datastore     = var.vsphere_datastore
    pool          = var.vsphere_resource_pool
    network = [
      var.vsphere_network
    ]
    cpu_count   = 2
    memory_size = 4096
    cfgparam = [
      "disk.enableUUID=TRUE"
    ]
  }
}

resource "rancher2_node_template" "worker" {
  name        = "worker"
  description = "Template for worker nodes"

  cloud_credential_id = rancher2_cloud_credential.vcenter.id

  vsphere_config {
    clone_from    = var.vm_template_name
    creation_type = "template"
    datacenter    = var.vsphere_datacenter
    datastore     = var.vsphere_datastore
    pool          = var.vsphere_resource_pool
    network = [
      var.vsphere_network
    ]
    cpu_count   = 4
    memory_size = 16384
    cfgparam = [
      "disk.enableUUID=TRUE"
    ]
  }
}
