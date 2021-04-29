resource "null_resource" "rancher3" {
  depends_on = [
    aws_instance.proxy,
    aws_instance.cluster_vms
  ]
  provisioner "remote-exec" {
    inline = [
      "ssh -oStrictHostKeyChecking=no ubuntu@${aws_instance.cluster_vms[0].private_ip} 'sudo cat /etc/rancher/k3s/k3s.yaml' > kube_config_k3s.yaml",
      "sed -i \"s/127.0.0.1/${aws_instance.cluster_vms[0].private_ip}/g\" kube_config_k3s.yaml",
      "helm repo add rancher-latest https://releases.rancher.com/server-charts/latest",
      "helm repo add jetstack https://charts.jetstack.io",
      "kubectl --kubeconfig kube_config_k3s.yaml create namespace cert-manager || true",
      "kubectl --kubeconfig kube_config_k3s.yaml create namespace cattle-system || true",
      "helm --kubeconfig kube_config_k3s.yaml upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.2.0 --set installCRDs=true --set http_proxy=http://${aws_instance.proxy.private_ip}:8888 --set https_proxy=http://${aws_instance.proxy.private_ip}:8888 --set no_proxy=127.0.0.0/8\\\\,10.0.0.0/8\\\\,172.16.0.0/12\\\\,192.168.0.0/16",
      "kubectl --kubeconfig kube_config_k3s.yaml rollout status deployment -n cert-manager cert-manager",
      "kubectl --kubeconfig kube_config_k3s.yaml rollout status deployment -n cert-manager cert-manager-webhook",
      "sleep 60", // hack: wait until webhook certificate was created
      "helm --kubeconfig kube_config_k3s.yaml upgrade --install rancher rancher-latest/rancher --namespace cattle-system --set hostname=${local.rancher_hostname} --set proxy=http://${aws_instance.proxy.private_ip}:8888  --set noProxy=127.0.0.0/8\\\\,10.0.0.0/8\\\\,172.16.0.0/12\\\\,192.168.0.0/16\\\\,.svc\\\\,.cluster.local",
      "kubectl --kubeconfig kube_config_k3s.yaml rollout status deployment -n cattle-system rancher",
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.proxy.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }
}