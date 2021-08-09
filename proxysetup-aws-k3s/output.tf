output "proxy_ip" {
  value = [aws_instance.proxy.public_ip]
}
output "proxy_private_ip" {
  value = [aws_instance.proxy.private_ip]
}
output "cluster_vm_ips" {
  value = [aws_instance.cluster_vms.*.private_ip]
}
output "dns_name" {
  value = local.rancher_hostname
}
output "add_vm_ips" {
  value = [aws_instance.additional_vms.*.private_ip]
}