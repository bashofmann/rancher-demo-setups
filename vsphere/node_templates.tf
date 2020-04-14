resource "rancher2_cloud_credential" "vsphere" {
  name = "vsphere"
  depends_on = [
    rancher2_bootstrap.admin
  ]
  provider = rancher2.admin

  vsphere_credential_config {
    username = var.vcenter_user
    password = var.vcenter_password
    vcenter = var.vcenter_server
  }
}

resource "rancher2_node_template" "controlplane" {
  name = "controlplane"
  description = "Template for control plane nodes"
  provider = rancher2.admin

  cloud_credential_id = rancher2_cloud_credential.vsphere.id

  vsphere_config {
    clone_from = var.vm_template_name
    creation_type = "template"
    datacenter = var.vsphere_datacenter
    datastore = var.vsphere_datastore
    pool = var.vsphere_resource_pool
    network = [
      var.vsphere_network
    ]
    cpu_count = var.node_num_cpus
    memory_size = var.node_memory_mb
    cloud_config = file("${path.module}/userdata/cloud-init.yaml")
    cfgparam = [
      "disk.enableUUID=TRUE"
    ]
  }
}

resource "rancher2_node_template" "worker" {
  name = "worker"
  description = "Template for worker nodes"
  provider = rancher2.admin

  cloud_credential_id = rancher2_cloud_credential.vsphere.id

  vsphere_config {
    clone_from = var.vm_template_name
    creation_type = "template"
    datacenter = var.vsphere_datacenter
    datastore = var.vsphere_datastore
    pool = var.vsphere_resource_pool
    network = [
      var.vsphere_network
    ]
    cpu_count = var.node_num_cpus_worker
    memory_size = var.node_memory_mb_worker
    cloud_config = file("${path.module}/userdata/cloud-init.yaml")
    cfgparam = [
      "disk.enableUUID=TRUE"
    ]
  }
}
