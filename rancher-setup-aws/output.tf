output "controlplane-nodetemplate-id" {
  value = rancher2_node_template.controlplane.id
}

output "worker-nodetemplate-id" {
  value = rancher2_node_template.worker.id
}