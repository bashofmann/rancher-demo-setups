resource "rancher2_cluster" "harvester" {
  depends_on = [
    rancher2_node_template.harvester
  ]
  name        = "${var.prefix}-harvester"
  description = "Cluster for harvester demo"
  cluster_auth_endpoint {
    enabled = true
  }
  rke_config {
    kubernetes_version = "v1.19.7-rancher1-1"
    addons             = file("cni_multus_flannel.yaml")
    network {
      plugin = "none"
    }
    services {
      kubelet {
        extra_args = {
          cni-conf-dir = "/etc/cni/net.d"
          cni-bin-dir  = "/opt/cni/bin"
        }
      }
    }
  }
}
resource "rancher2_node_pool" "harvester" {
  cluster_id       = rancher2_cluster.harvester.id
  name             = "harvester"
  hostname_prefix  = "${var.prefix}-harvester"
  node_template_id = rancher2_node_template.harvester.id
  quantity         = 3
  control_plane    = true
  etcd             = true
  worker           = true
}

resource "rancher2_cluster_sync" "harvester" {
  cluster_id = rancher2_cluster.harvester.id

  node_pool_ids = [
    rancher2_node_pool.harvester.id,
  ]

  state_confirm = 4
}

resource "local_file" "kube_config" {
  filename        = "out/kube_config_demo.yaml"
  content         = rancher2_cluster_sync.harvester.kube_config
  file_permission = "0600"
}
