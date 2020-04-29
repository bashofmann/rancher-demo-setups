resource "rancher2_node_pool" "demo-control" {
  cluster_id       = var.cluster_id
  name             = "demo-control"
  hostname_prefix  = "${var.prefix}-demo-control"
  node_template_id = var.controlplane-nodetemplate-id
  quantity         = 3
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "demo-worker" {
  cluster_id       = var.cluster_id
  name             = "demo-worker"
  hostname_prefix  = "${var.prefix}-demo-worker"
  node_template_id = var.worker-nodetemplate-id
  quantity         = 4
  control_plane    = false
  etcd             = false
  worker           = true
}

resource "rancher2_cluster_sync" "demo" {
  cluster_id      = var.cluster_id
  node_pool_ids = [
    rancher2_node_pool.demo-control.id,
    rancher2_node_pool.demo-worker.id
  ]

  provisioner "local-exec" {
    command = "while ! kubectl cluster-info; do echo 'waiting for cluster' && sleep 1; done"
    interpreter = ["bash", "-c"]
    environment = {
        KUBECONFIG = var.cluster_kubeconfig
    }
  }
}