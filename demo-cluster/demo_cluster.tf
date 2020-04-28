resource "rancher2_cluster" "demo" {
  name        = "demo"
  description = "Cluster for demos"
  rke_config {
    kubernetes_version = var.rke_kubernetes_version
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
      drain = true
      drain_input {
        delete_local_data = true
        force             = true
      }
      max_unavailable_worker = "20%"
    }
  }
  enable_cluster_monitoring = true
  scheduled_cluster_scan {
    enabled = true
    scan_config {
      cis_scan_config {
        profile = "permissive"
      }
    }
    schedule_config {
      cron_schedule = "30 * * * *"
      retention     = 5
    }
  }
}

resource "rancher2_node_pool" "demo-control" {
  cluster_id       = rancher2_cluster.demo.id
  name             = "demo-control"
  hostname_prefix  = "${var.prefix}-demo-control"
  node_template_id = var.controlplane-nodetemplate-id
  quantity         = 3
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "demo-worker" {
  cluster_id       = rancher2_cluster.demo.id
  name             = "demo-worker"
  hostname_prefix  = "${var.prefix}-demo-worker"
  node_template_id = var.worker-nodetemplate-id
  quantity         = 4
  control_plane    = false
  etcd             = false
  worker           = true
}

resource "rancher2_cluster_sync" "demo" {
  cluster_id      = rancher2_cluster.demo.id
  wait_monitoring = true
  node_pool_ids = [
    rancher2_node_pool.demo-control.id,
    rancher2_node_pool.demo-worker.id
  ]
}