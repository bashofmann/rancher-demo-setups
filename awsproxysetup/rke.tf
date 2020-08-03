resource "null_resource" "rke" {
  triggers = {
    filehash = filesha256(abspath("${path.module}/rke-cluster.yaml"))
  }
  provisioner "local-exec" {
    command = "scp rke-cluster.yaml ubuntu@${aws_instance.proxy.public_ip}:~"
  }
  provisioner "remote-exec" {
    inline = [
      "rke up --config rke-cluster.yaml",
      "kubectl cluster-info --kubeconfig kube_config_rke-cluster.yaml"
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.proxy.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }
}