resource "local_file" "kube_config" {
  depends_on = [
    rancher2_cluster_sync.demo
  ]
  filename = "${var.output_dir}/kube_config_demo.yml"
  content  = rancher2_cluster.demo.kube_config
}
output "kubeconfig" {
  value = abspath(local_file.kube_config.filename)
}