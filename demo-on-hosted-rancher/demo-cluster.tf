module "demo-cluster-aws" {
  source                 = "../modules/demo-cluster-aws"
  rancher_url            = var.rancher_url
  rancher_access_key     = var.rancher_access_key
  rancher_secret_key     = var.rancher_secret_key
  rke_kubernetes_version = "v1.16.9-rancher1-1"
  output_dir             = abspath("${path.module}/out")
}

module "demo-cluster" {
  source                       = "../modules/demo-cluster"
  rancher_url                  = var.rancher_url
  rancher_access_key           = var.rancher_access_key
  rancher_secret_key           = var.rancher_secret_key
  cluster_id                   = module.demo-cluster-aws.cluster_id
  cluster_name                 = module.demo-cluster-aws.cluster_name
  cluster_kubeconfig           = module.demo-cluster-aws.kubeconfig
  controlplane-nodetemplate-id = module.rancher-setup.controlplane-nodetemplate-id
  worker-nodetemplate-id       = module.rancher-setup.worker-nodetemplate-id
}

module "demo-workloads" {
  source                    = "../modules/demo-workloads"
  digitalocean_token        = var.digitalocean_token
  dns_txt_owner_id          = "rancher-demo-hosted-aws"
  kubeconfig_demo           = module.demo-cluster-aws.kubeconfig
  email                     = var.email
  ingress_base_domain       = "rancher-demo.plgrnd.be"
  rancher_system_project_id = module.demo-cluster.rancher_system_project_id
}