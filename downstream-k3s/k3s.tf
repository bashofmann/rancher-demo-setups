resource "null_resource" "k3s" {
  provisioner "local-exec" {
    command = "bash install_k3s.sh"
    environment = {
      IP0 = aws_instance.k3s[0].public_ip
      IP1 = aws_instance.k3s[1].public_ip
      IP2 = aws_instance.k3s[2].public_ip
      IP3 = aws_instance.k3s[3].public_ip
      IP4 = aws_instance.k3s[4].public_ip
    }
  }
}