
output "cluster_id" {
  depends_on = [
    rancher2_namespace.shop,
    rancher2_app_v2.longhorn,
    rancher2_app_v2.rancher-istio,
  ]
  value = rancher2_cluster_sync.demo.cluster_id
}