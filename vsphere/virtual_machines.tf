data "vsphere_virtual_machine" "ubuntu" {
  name          = var.vm_template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Creates and provisions VMs for the cluster
resource "vsphere_virtual_machine" "rancher_server" {
  count            = var.rancher_num_cluster_nodes
  name             = "${var.cluster_nodes_name_prefix}-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = var.node_num_cpus
  memory    = var.node_memory_mb
  guest_id  = data.vsphere_virtual_machine.ubuntu.guest_id

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
      hostname = "${var.cluster_nodes_name_prefix}-${count.index}"
      public-keys = trimspace(file("${var.ssh_key_file_name}.pub"))
      user-data = base64encode(templatefile("userdata/server.sh", {
          docker_version = var.docker_version
          username       = local.node_username
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
      user        = local.node_username
      private_key = file(var.ssh_key_file_name)
    }
  }
}