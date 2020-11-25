resource "rancher2_cluster" "demo" {
  name        = "${var.prefix}-demo"
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
      drain                  = false
      max_unavailable_worker = "20%"
    }
    cloud_provider {
      aws_cloud_provider {
      }
    }
  }
}