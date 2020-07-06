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
    // todo add vsphere cloud provider
    //    cloud_provider {
    //      aws_cloud_provider {
    //      }
    //    }
  }
  enable_cluster_monitoring = true
  lifecycle {
    ignore_changes = [
      enable_cluster_istio
    ]
  }
  scheduled_cluster_scan {
    enabled = true
    scan_config {
      cis_scan_config {
        override_benchmark_version = "rke-cis-1.4"
        profile                    = "permissive"
      }
    }
    schedule_config {
      cron_schedule = "30 * * * *"
      retention     = 5
    }
  }
}