output "node_ips" {
  value = aws_instance.vmlb.*.public_ip
}