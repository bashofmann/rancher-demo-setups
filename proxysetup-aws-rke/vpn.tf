resource "null_resource" "get_vpn_config" {
  provisioner "local-exec" {
    command = "scp -oStrictHostKeyChecking=no ubuntu@${aws_instance.proxy.public_ip}:awsproxysetup.ovpn ."
  }
}