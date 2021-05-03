locals {
  rancher_hostname = join(".", ["rancher", aws_instance.proxy.private_ip, "nip.io"])
}