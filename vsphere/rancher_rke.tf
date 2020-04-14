## Module to render template file ##
resource "local_file" "rke_configuration" {
  depends_on = [
    vsphere_virtual_machine.rancher_server
  ]
  filename = "${path.module}/rke-rendered.yml"
  content = templatefile("${path.module}/rke-config.tmpl", {
    ip_addrs = vsphere_virtual_machine.rancher_server[*].default_ip_address
    kubernetes_version = var.rke_kubernetes_version
  })
}

## Boot up cluster ##
resource "null_resource" "rke_bootup" {
  depends_on = [
    local_file.rke_configuration
  ]

  provisioner "local-exec" {
      command = "rke up"
      environment = {
        RKE_CONFIG = local_file.rke_configuration.filename
      }
  }
}
