resource "rancher2_cloud_credential" "do-harvester" {
  name = "${var.prefix}-do-harvester"

  digitalocean_credential_config {
    access_token = var.digitalocean_token
  }
}

resource "rancher2_node_template" "harvester" {
  name        = "${var.prefix}-do-harvester"
  description = "Template for harvester nodes"

  cloud_credential_id = rancher2_cloud_credential.do-harvester.id
  engine_install_url  = "https://releases.rancher.com/install-docker/${var.docker_version}.sh"

  digitalocean_config {
    image    = "ubuntu-20-04-x64"
    region   = "fra1"
    size     = "s-8vcpu-32gb"
    userdata = ""
  }
}



