data "vsphere_virtual_machine" "ubuntu" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
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
# Creates and provisions VMs for the cluster
resource "vsphere_virtual_machine" "etcd-nodes" {
  count            = 3
  name             = "${var.prefix}-etcd-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = 2
  memory   = 8192
  guest_id = data.vsphere_virtual_machine.ubuntu.guest_id

  scsi_type = data.vsphere_virtual_machine.ubuntu.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.ubuntu.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.ubuntu.disks.0.size
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.ubuntu.disks.0.thin_provisioned
  }

  cdrom {
    client_device = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu.id
  }

  vapp {
    properties = {
      hostname    = "${var.prefix}-etcd-${count.index}"
      public-keys = trimspace(file("${var.ssh_key_file_name}.pub"))
      user-data = base64encode(templatefile("../userdata/server.sh", {
        docker_version = "19.03"
        username       = "ubuntu"
      }))
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait"
    ]

    connection {
      type        = "ssh"
      host        = self.default_ip_address
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }
}