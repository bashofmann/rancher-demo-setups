data "rancher2_project" "system" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  cluster_id = rancher2_cluster.demo.id
  name       = "System"
}

resource "rancher2_namespace" "longhorn-system" {
  name       = "longhorn-system"
  project_id = data.rancher2_project.system.id
}

resource "rancher2_app" "longhorn-system" {
  catalog_name     = "library"
  name             = "longhorn-system"
  project_id       = data.rancher2_project.system.id
  template_name    = "longhorn"
  template_version = "0.8.0"
  target_namespace = rancher2_namespace.longhorn-system.name
  lifecycle {
    ignore_changes = [
      project_id
    ]
  }
}

resource "rancher2_project" "shop" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  cluster_id = rancher2_cluster.demo.id
  name       = "Shop"
}

resource "rancher2_namespace" "shop" {
  name       = "shop"
  project_id = rancher2_project.shop.id
}