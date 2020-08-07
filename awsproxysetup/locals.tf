locals {
  rancher_hostname = join(".", ["rancher", aws_instance.proxy.public_ip, "xip.io"])
}