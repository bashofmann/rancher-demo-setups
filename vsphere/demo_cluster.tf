resource "rancher2_cluster" "demo" {
  name = "demo"
  description = "Cluster for demostructure components"
  depends_on = [
    rancher2_bootstrap.admin
  ]
  provider = rancher2.admin
  rke_config {
    kubernetes_version = var.rke_kubernetes_version
    network {
      plugin = "canal"
    }
    services {
      etcd {
        creation = "6h"
        retention = "24h"
      }
    }
    upgrade_strategy {
      drain = true
      max_unavailable_worker = "20%"
    }
  }
  enable_cluster_alerting = true
  enable_cluster_monitoring = true
  scheduled_cluster_scan {
    enabled = true
    scan_config {
      cis_scan_config {
        debug_master = true
        debug_worker = true
      }
    }
    schedule_config {
      cron_schedule = "30 * * * *"
      retention = 5
    }
  }
}

resource "rancher2_node_pool" "demo-control" {
  cluster_id =  rancher2_cluster.demo.id
  name = "demo-control"
  provider = rancher2.admin
  hostname_prefix =  "${var.cluster_nodes_name_prefix}-demo-control"
  node_template_id = rancher2_node_template.controlplane.id
  quantity = 3
  control_plane = true
  etcd = true
  worker = false
}

resource "rancher2_node_pool" "demo-worker" {
  cluster_id =  rancher2_cluster.demo.id
  name = "demo-worker"
  provider = rancher2.admin
  hostname_prefix =  "${var.cluster_nodes_name_prefix}-demo-worker"
  node_template_id = rancher2_node_template.worker.id
  quantity = 5
  control_plane = false
  etcd = false
  worker = true
}

resource "rancher2_cluster_sync" "demo" {
  provider = rancher2.admin
  cluster_id =  rancher2_cluster.demo.id
  node_pool_ids = [
    rancher2_node_pool.demo-control.id,
    rancher2_node_pool.demo-worker.id
  ]
}