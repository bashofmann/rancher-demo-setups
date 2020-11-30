resource "rancher2_cluster" "cluster" {
  name = "bhofmann-windows"

  rke_config {
    network {
      plugin = "canal"
    }
    kubernetes_version = "v1.18.12-rancher1-1"
  }
  windows_prefered_cluster = true
}
