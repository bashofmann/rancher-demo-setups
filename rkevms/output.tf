output "node_ips" {
  value = [aws_instance.rancher-cluster.*.public_ip]
}
