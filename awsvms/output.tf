output "rancher_cluster_node_ips" {
  value = [aws_instance.rancher-cluster.*.public_ip]
}

output "downstream_cluster_node_ips" {
  value = [aws_instance.downstream-cluster.*.public_ip]
}

output "lb_ip" {
  value = aws_elb.rancher-server-lb.dns_name
}