resource "kubernetes_daemonset" "ssh-key" {
  depends_on = [
    local_file.kube_config
  ]
  metadata {
    name = "ssh-key"
  }
  spec {
    selector {
      match_labels = {
        app = "ssh-key"
      }
    }
    template {
      metadata {
        labels = {
          app = "ssh-key"
        }
      }
      spec {
        init_container {
          name  = "ssh-key"
          image = "alpine"
          command = ["/bin/sh",
          "-xc", "mkdir -p /host/root/.ssh && echo '${file("${var.ssh_key_file_name}.pub")}' > /host/root/.ssh/authorized_keys"]
          volume_mount {
            mount_path = "/host/root"
            name       = "root-home"
          }
        }
        container {
          name  = "sleep"
          image = "rancher/pause:3.2"
        }
        volume {
          name = "root-home"
          host_path {
            path = "/root"
          }
        }
      }
    }
  }
}