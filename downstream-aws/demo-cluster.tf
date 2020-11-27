resource "rancher2_cluster" "demo" {
  name        = "${var.prefix}-demo"
  description = "Cluster for demos"
  cluster_auth_endpoint {
    enabled = true
  }
  rke_config {
    kubernetes_version = "v1.18.12-rancher1-1"
    network {
      plugin = "canal"
    }
    services {
      etcd {
        creation  = "6h"
        retention = "24h"
      }
    }
    upgrade_strategy {
      drain                  = false
      max_unavailable_worker = "20%"
    }
    cloud_provider {
      aws_cloud_provider {
      }
    }
  }
}
resource "rancher2_node_pool" "demo-control" {
  cluster_id       = rancher2_cluster.demo.id
  name             = "demo-control"
  hostname_prefix  = "${var.prefix}-demo-control"
  node_template_id = rancher2_node_template.controlplane.id
  quantity         = 3
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "demo-worker" {
  cluster_id       = rancher2_cluster.demo.id
  name             = "demo-worker"
  hostname_prefix  = "${var.prefix}-demo-worker"
  node_template_id = rancher2_node_template.worker.id
  quantity         = 4
  control_plane    = false
  etcd             = false
  worker           = true
}

resource "rancher2_cluster_sync" "demo" {
  cluster_id = rancher2_cluster.demo.id
  node_pool_ids = [
    rancher2_node_pool.demo-control.id,
    rancher2_node_pool.demo-worker.id
  ]
}

resource "local_file" "kube_config" {
  filename        = "out/kube_config_demo.yml"
  content         = rancher2_cluster.demo.kube_config
  file_permission = "0600"
}

module "demo-workloads" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  source             = "../modules/demo-workloads"
  digitalocean_token = var.digitalocean_token
  kubeconfig_demo    = abspath(local_file.kube_config.filename)
  email              = var.email
}