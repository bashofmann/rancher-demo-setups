resource "aws_security_group" "rancher_sg_allowall" {
  name        = "bhofmann-rancher-allowall-k3s-proxy"
  description = "Rancher quickstart - allow all traffic"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Creator = "rancher-quickstart"
  }
}

resource "aws_instance" "rancher_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.medium"

  key_name        = aws_key_pair.ssh_key_pair.key_name
  security_groups = [aws_security_group.rancher_sg_allowall.name]

  user_data = templatefile("userdata/rancher_server.sh", {
  })

  root_block_device {
    volume_size = 16
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "cloud-init status --wait > /dev/null",
      "echo 'Completed cloud-init!'",
      "helm repo add rancher-latest https://releases.rancher.com/server-charts/latest",
      "helm --kubeconfig /etc/rancher/k3s/k3s.yaml upgrade --install rancher rancher-latest/rancher --namespace cattle-system --version 2.5.3 --set hostname=${join(".", ["rancher", self.public_ip, "xip.io"])} --create-namespace || true"
      "kubectl --kubeconfig /etc/rancher/k3s/k3s.yaml rollout status deployment -n cattle-system rancher"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file(var.ssh_key_file_name)
    }
  }

  tags = {
    Name    = "bhofmann-rancher-server"
    Creator = "rancher-quickstart"
  }
}