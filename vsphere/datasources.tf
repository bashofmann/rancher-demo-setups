data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.vsphere_resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "local_file" "kube_admin" {
  filename = "${path.module}/kube_config_rke-rendered.yml"
  depends_on = [
    null_resource.rke_bootup
  ]
}

data "local_file" "rke_state" {
  filename = "${path.module}/rke-rendered.rkestate"
  depends_on = [
    null_resource.rke_bootup
  ]
}