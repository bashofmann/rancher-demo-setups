resource "local_file" "kube_config" {
  filename = "${var.output_dir}/kube_config_demo.yml"
  content  = rancher2_cluster.demo.kube_config
}
output "kubeconfig" {
  value = abspath(local_file.kube_config.filename)
}
output "cluster_id" {
  value = rancher2_cluster.demo.id
}
output "cluster_name" {
  value = rancher2_cluster.demo.name
}