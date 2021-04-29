resource "null_resource" "k3s_0" {
  provisioner "local-exec" {
    command = "bash install_k3s.sh && mv kubeconfig kubeconfig_0"
    environment = {
      IP = aws_instance.cluster_one.public_ip
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm kubeconfig_0"
  }
}
resource "null_resource" "k3s_1" {
  provisioner "local-exec" {
    command = "bash install_k3s.sh && mv kubeconfig kubeconfig_1"
    environment = {
      IP = aws_instance.cluster_two.public_ip
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm kubeconfig_1"
  }
}
resource "null_resource" "k3s_2" {
  provisioner "local-exec" {
    command = "bash install_k3s.sh && mv kubeconfig kubeconfig_2"
    environment = {
      IP = aws_instance.cluster_three.public_ip
    }
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm kubeconfig_2"
  }
}
