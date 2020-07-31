locals {
  rancher_system_project_id = split(":", data.rancher2_project.system.id)[1]
}
output "rancher_system_project_id" {
  value = local.rancher_system_project_id
}
output "cluster_id" {
  depends_on = [
    rancher2_namespace.shop,
    rancher2_app.longhorn,
    rancher2_app.istio,
  ]
  value = rancher2_cluster_sync.demo.cluster_id
}