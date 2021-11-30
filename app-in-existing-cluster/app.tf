//data "rancher2_cluster" "local" {
//  name = "bhofmann-demo"
//}
resource "rancher2_cluster" "foo-imported" {
  name        = "bhofmann-imported"
  description = "Foo rancher2 imported cluster"
  agent_env_vars {
    name  = "name1"
    value = "value1"
  }
  agent_env_vars {
    name  = "name2"
    value = "value2"
  }
}
//resource "rancher2_project" "grafana" {
//  cluster_id = data.rancher2_cluster.local.id
//  name = "grafana"
//}
//
//resource "rancher2_namespace" "grafana" {
//  name = "grafana"
//  project_id = rancher2_project.grafana.id
//}

//resource "rancher2_catalog_v2" "grafana" {
//  cluster_id = data.rancher2_cluster.local.id
//  name = "grafana"
//  git_repo = "https://grafana.github.io/helm-charts"
//  git_branch = "main"
//}

//resource "rancher2_cluster_sync" "sync" {
//  cluster_id = data.rancher2_cluster.local.id
//  wait_catalogs = true
//}
//
//resource "rancher2_app_v2" "rancher-cis-benchmark" {
//  cluster_id = rancher2_cluster_sync.sync.cluster_id
//  name = "grafana"
//  namespace = rancher2_namespace.grafana.name
//  repo_name = rancher2_catalog_v2.grafana.name
//  chart_name = "grafana"
//  chart_version = "6.6.3"
//}