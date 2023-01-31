resource "rancher2_cloud_credential" "do" {
  name = "${var.prefix}-do"

  digitalocean_credential_config {
    access_token = var.digitalocean_token
  }
}

locals {
  os_version = "ubuntu-22-04-x64"
}

resource "rancher2_node_template" "do" {
  name = "${var.prefix}-do"

  cloud_credential_id = rancher2_cloud_credential.do.id
  engine_install_url  = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"

  digitalocean_config {
    image    = local.os_version
    region   = "fra1"
    size     = "s-8vcpu-32gb"
    userdata = ""
  }
}

resource "rancher2_node_template" "dow" {
  name = "${var.prefix}-do"

  cloud_credential_id = rancher2_cloud_credential.do.id
  engine_install_url  = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"

  digitalocean_config {
    image    = local.os_version
    region   = "fra1"
    size     = "s-4vcpu-8gb"
    userdata = ""
  }
}


