resource "rancher2_catalog" "harvester" {
  name       = "harvester"
  url        = "https://github.com/rancher/harvester"
  version    = "helm_v3"
  scope      = "cluster"
  cluster_id = rancher2_cluster_sync.harvester.id
}

resource "rancher2_project" "harvester" {
  name       = "harvester"
  cluster_id = rancher2_cluster.harvester.id
}

resource "rancher2_namespace" "harvester" {
  name       = "harvester-system"
  project_id = rancher2_project.harvester.id
}

resource "rancher2_app" "harvester" {
  catalog_name     = "${rancher2_cluster.harvester.id}:${rancher2_catalog.harvester.name}"
  name             = "harvester-system"
  project_id       = rancher2_project.harvester.id
  template_name    = "harvester"
  template_version = "0.1.0"
  target_namespace = rancher2_namespace.harvester.id
  answers = {
    "longhorn.enabled" = true
  }
}