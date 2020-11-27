resource "null_resource" "workload" {
  triggers = {
    filehash = sha256(join(",", flatten([
      for filename in fileset(path.module, "**") : filesha256(abspath("${path.module}/${filename}"))
      ]
    )))
  }
  provisioner "local-exec" {
    command = "make -C ${path.module} install"
    environment = {
      KUBECONFIG                 = var.kubeconfig_demo
      EMAIL                      = var.email
      DIGITALOCEAN_TOKEN         = var.digitalocean_token
      ENCODED_DIGITALOCEAN_TOKEN = base64encode(var.digitalocean_token)
      HELM_EXPERIMENTAL_OCI      = 1
    }
  }
}