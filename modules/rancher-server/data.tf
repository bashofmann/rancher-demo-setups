data "local_file" "kube_admin" {
  filename = "${var.output_dir}/kube_config_rke-rendered.yml"
  depends_on = [
    null_resource.rke_bootup
  ]
}

data "local_file" "rke_state" {
  filename = "${var.output_dir}/rke-rendered.rkestate"
  depends_on = [
    null_resource.rke_bootup
  ]
}