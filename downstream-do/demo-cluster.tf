resource "rancher2_cluster" "do" {
  depends_on = [
    rancher2_node_template.do
  ]
  name = "${var.prefix}-do"
  cluster_auth_endpoint {
    enabled = true
  }
  rke_config {
    kubernetes_version = "v1.19.7-rancher1-1"
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

resource "rancher2_node_pool" "do-cp" {
  cluster_id       = rancher2_cluster.do.id
  name             = "do-cp"
  hostname_prefix  = "${var.prefix}-doc"
  node_template_id = rancher2_node_template.do.id
  quantity         = 3
  control_plane    = true
  etcd             = true
  worker           = false
}

resource "rancher2_node_pool" "do-w-1" {
  cluster_id       = rancher2_cluster.do.id
  name             = "do-1w"
  hostname_prefix  = "${var.prefix}-do1w"
  node_template_id = rancher2_node_template.dow.id
  quantity         = 2
  control_plane    = false
  etcd             = false
  worker           = true
  labels = {
    version = "1"
  }

  #  lifecycle {
  #    create_before_destroy = true
  #    replace_triggered_by = [
  #      rancher2_node_template.dow,
  #    ]
  #  }
}

resource "rancher2_cluster_sync" "harvester" {
  cluster_id = rancher2_cluster.do.id

  node_pool_ids = [
    rancher2_node_pool.do-cp.id,
    rancher2_node_pool.do-w-1.id,
  ]

  state_confirm = 4
}

resource "local_file" "kube_config" {
  filename        = "out/kube_config_demo.yaml"
  content         = rancher2_cluster_sync.harvester.kube_config
  file_permission = "0600"
}
