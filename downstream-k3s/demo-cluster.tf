//resource "rancher2_cluster" "demo" {
//  name        = "${var.prefix}-demo"
//  description = "Cluster for demos"
//}
//
//resource "null_resource" "registration" {
//  depends_on = [
//    null_resource.k3s,
//    rancher2_cluster.demo
//  ]
//  provisioner "local-exec" {
//    command = rancher2_cluster.demo.cluster_registration_token[0].command
//    environment = {
//      KUBECONFIG = "${path.module}/kubeconfig"
//    }
//  }
//}

module "demo-workloads" {
  depends_on = [
    null_resource.k3s
  ]
  source             = "../modules/demo-workloads"
  digitalocean_token = var.digitalocean_token
  kubeconfig_demo    = abspath("${path.module}/kubeconfig")
  email              = var.email
}