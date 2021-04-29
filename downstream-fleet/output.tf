output "node_ips" {
  value = [
    aws_instance.cluster_one.public_ip,
    aws_instance.cluster_two.public_ip,
    aws_instance.cluster_three.public_ip,
    aws_instance.cluster_four.public_ip,
  ]
}