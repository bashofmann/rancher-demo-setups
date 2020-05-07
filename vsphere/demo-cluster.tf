module "demo-cluster-vsphere" {
  source                 = "../modules/demo-cluster-vsphere"
  rancher_url            = module.rancher-server.rancher_url
  rancher_admin_token    = module.rancher-server.rancher_admin_token
  rke_kubernetes_version = "v1.16.9-rancher1-1"
  output_dir             = abspath("${path.module}/out")
}

module "demo-cluster" {
  source                       = "../modules/demo-cluster"
  rancher_url                  = module.rancher-server.rancher_url
  rancher_admin_token          = module.rancher-server.rancher_admin_token
  cluster_id                   = module.demo-cluster-vsphere.cluster_id
  cluster_name                 = module.demo-cluster-vsphere.cluster_name
  cluster_kubeconfig           = module.demo-cluster-vsphere.kubeconfig
  controlplane-nodetemplate-id = module.rancher-setup.controlplane-nodetemplate-id
  worker-nodetemplate-id       = module.rancher-setup.worker-nodetemplate-id
  output_dir                   = abspath("${path.module}/out")
}

module "demo-workloads" {
  source              = "../modules/demo-workloads"
  digitalocean_token  = var.digitalocean_token
  dns_txt_owner_id    = "rancher-demo-vsphere"
  kubeconfig_demo     = module.demo-cluster-vsphere.kubeconfig
  email               = var.email
  ingress_base_domain = "rancher-vsphere.plgrnd.be"
  cluster_id                = module.demo-cluster.cluster_id
  rancher_system_project_id = module.demo-cluster.rancher_system_project_id
}