resource "vsphere_virtual_machine" "k3s_server" {
  name             = "${var.cluster_nodes_name_prefix}-k3s-server"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = 1
  memory    = 1024
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
      hostname = "${var.cluster_nodes_name_prefix}-k3s-server"
      public-keys = trimspace(file("${var.ssh_key_file_name}.pub"))
      user-data = base64encode(templatefile("../../userdata/k3s.sh", {
          docker_version = var.docker_version
          username       = local.node_username
          k3s_token      = var.k3s_token
          k3s_url        = ""
          register_manifest_url = rancher2_cluster.k3s.cluster_registration_token[0].manifest_url
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

resource "vsphere_virtual_machine" "k3s_agent" {
  count = 1
  name             = "${var.cluster_nodes_name_prefix}-k3s-agent-${count.index}"
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus  = 1
  memory    = 1024
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
      hostname = "${var.cluster_nodes_name_prefix}-k3s-agent-${count.index}"
      public-keys = trimspace(file("${var.ssh_key_file_name}.pub"))
      user-data = base64encode(templatefile("../userdata/k3s.sh", {
          docker_version = var.docker_version
          username       = local.node_username
          k3s_token      = var.k3s_token
          k3s_url        = "https://${vsphere_virtual_machine.k3s_server.default_ip_address}:6443"
          register_manifest_url = ""
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

resource "rancher2_cluster" "k3s" {
  name = "k3s"
  depends_on = [
    rancher2_bootstrap.admin
  ]
  provider = rancher2.admin
}
