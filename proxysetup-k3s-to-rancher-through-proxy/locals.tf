locals {
  rancher_hostname = join(".", ["rancher", aws_instance.rancher_server.public_ip, "nip.io"])
}