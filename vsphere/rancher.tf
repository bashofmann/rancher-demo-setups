# Install Rancher

resource "local_file" "certificate" {
  filename = "${path.module}/certificate/certificate.yaml"
  content = templatefile("${path.module}/certificate/certificate.yaml.tmpl", {
    rancher_hostname = digitalocean_record.rancher.fqdn
    digitalocean_token = base64encode(var.digitalocean_token)
    email = var.email
  })
}

resource "null_resource" "rancher" {
  depends_on = [
    data.local_file.kube_admin
  ]

  provisioner "local-exec" {
      command = "make install-rancher"
      environment = {
        KUBECONFIG = data.local_file.kube_admin.filename
        CERT_MANAGER_VERSION = var.cert_manager_version
        RANCHER_VERSION = var.rancher_version
        RANCHER_HOSTNAME = digitalocean_record.rancher.fqdn
      }
  }
}

# Initialize Rancher server
resource "rancher2_bootstrap" "admin" {
  depends_on = [
    null_resource.rancher
  ]

  provider = rancher2.bootstrap

  password  = var.rancher_admin_password
  telemetry = true
}