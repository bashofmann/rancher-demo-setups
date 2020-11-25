module "demo-cluster-vsphere" {
  source                 = "../modules/demo-cluster-vsphere"
  rancher_url            = var.rancher_url
  rancher_access_key     = var.rancher_access_key
  rancher_secret_key     = var.rancher_secret_key
  rke_kubernetes_version = "v1.18.12-rancher1-1"
  output_dir             = abspath("${path.module}/out")
}

module "demo-cluster" {
  source                       = "../modules/demo-cluster"
  rancher_url                  = var.rancher_url
  rancher_access_key           = var.rancher_access_key
  rancher_secret_key           = var.rancher_secret_key
  cluster_id                   = module.demo-cluster-vsphere.cluster_id
  cluster_name                 = module.demo-cluster-vsphere.cluster_name
  cluster_kubeconfig           = module.demo-cluster-vsphere.kubeconfig
  controlplane-nodetemplate-id = module.rancher-setup.controlplane-nodetemplate-id
  worker-nodetemplate-id       = module.rancher-setup.worker-nodetemplate-id
}