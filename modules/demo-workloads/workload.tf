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
      DNS_TXT_OWNER_ID           = var.dns_txt_owner_id
      INGRESS_BASE_DOMAIN        = var.ingress_base_domain
      CLUSTER_ID                 = var.cluster_id
      RANCHER_SYSTEM_PROJECT_ID  = var.rancher_system_project_id
    }
  }
}