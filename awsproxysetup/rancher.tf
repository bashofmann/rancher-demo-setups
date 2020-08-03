resource "null_resource" "rancher" {
  depends_on = [
    null_resource.rke
  ]
  provisioner "remote-exec" {
    inline = [
      "helm repo add rancher-latest https://releases.rancher.com/server-charts/latest",
      "helm repo add jetstack https://charts.jetstack.io",
      "kubectl --kubeconfig kube_config_rke-cluster.yaml create namespace cert-manager || true",
      "kubectl --kubeconfig kube_config_rke-cluster.yaml create namespace cattle-system || true",
      "helm --kubeconfig kube_config_rke-cluster.yaml upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.15.2 --set installCRDs=true --set http_proxy=http://${aws_instance.proxy.private_ip}:8888 --set https_proxy=http://${aws_instance.proxy.private_ip}:8888 --set no_proxy=127.0.0.0/8\\\\,10.0.0.0/8\\\\,172.16.0.0/12\\\\,192.168.0.0/16",
      "kubectl --kubeconfig kube_config_rke-cluster.yaml rollout status deployment -n cert-manager cert-manager",
      "kubectl --kubeconfig kube_config_rke-cluster.yaml rollout status deployment -n cert-manager cert-manager-webhook",
      "sleep 60", // hack: wait until webhook certificate was created
      "helm --kubeconfig kube_config_rke-cluster.yaml upgrade --install rancher rancher-latest/rancher --namespace cattle-system --set hostname=${digitalocean_record.rancher.fqdn} --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=mail@bastianhofmann.de --set proxy=http://${aws_instance.proxy.private_ip}:8888",
      "kubectl --kubeconfig kube_config_rke-cluster.yaml rollout status deployment -n cattle-system rancher",
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.proxy.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }
}