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
  cluster_monitoring_input {
    answers = {
      "exporter-kubelets.https"                   = true
      "exporter-node.enabled"                     = true
      "exporter-node.ports.metrics.port"          = 9796
      "exporter-node.resources.limits.cpu"        = "200m"
      "exporter-node.resources.limits.memory"     = "200Mi"
      "grafana.persistence.enabled"               = false
      "grafana.persistence.size"                  = "10Gi"
      "grafana.persistence.storageClass"          = "default"
      "operator.resources.limits.memory"          = "500Mi"
      "prometheus.persistence.enabled"            = "false"
      "prometheus.persistence.size"               = "50Gi"
      "prometheus.persistence.storageClass"       = "default"
      "prometheus.persistent.useReleaseName"      = "true"
      "prometheus.resources.core.limits.cpu"      = "1000m",
      "prometheus.resources.core.limits.memory"   = "1500Mi"
      "prometheus.resources.core.requests.cpu"    = "750m"
      "prometheus.resources.core.requests.memory" = "750Mi"
      "prometheus.retention"                      = "12h"
    }
    version = "0.1.2"
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