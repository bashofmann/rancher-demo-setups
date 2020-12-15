resource "rancher2_cluster" "cluster" {
  name = "bhofmann-windows"

  rke_config {
    network {
      plugin = "flannel"
      options = {
        flannel_backend_port = "4789"
        flannel_backend_type = "vxlan"
        flannel_backend_vni  = "4096"
      }
    }
    kubernetes_version = "v1.18.12-rancher1-1"
  }
  windows_prefered_cluster = true
}
