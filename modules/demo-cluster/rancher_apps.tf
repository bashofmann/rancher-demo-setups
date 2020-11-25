resource "rancher2_app_v2" "rancher-monitoring" {
  cluster_id    = rancher2_cluster_sync.demo.id
  name          = "rancher-monitoring"
  namespace     = "cattle-monitoring-system"
  repo_name     = "rancher-charts"
  chart_name    = "rancher-monitoring"
  chart_version = "9.4.201"
}

resource "rancher2_app_v2" "rancher-istio" {
  depends_on = [
    rancher2_app_v2.rancher-monitoring
  ]
  cluster_id    = rancher2_cluster_sync.demo.id
  name          = "rancher-istio"
  namespace     = "istio-system"
  repo_name     = "rancher-charts"
  chart_name    = "rancher-istio"
  chart_version = "1.7.300"
}

resource "rancher2_app_v2" "longhorn" {
  cluster_id    = rancher2_cluster_sync.demo.id
  name          = "longhorn"
  namespace     = "longhorn-system"
  repo_name     = "rancher-charts"
  chart_name    = "longhorn"
  chart_version = "1.0.201"
}

resource "rancher2_project" "shop" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  cluster_id = rancher2_cluster_sync.demo.id
  name       = "Shop"
}

resource "rancher2_namespace" "shop" {
  name       = "shop"
  project_id = rancher2_project.shop.id
}