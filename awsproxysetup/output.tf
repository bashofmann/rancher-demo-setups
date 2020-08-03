output "proxy_ip" {
  value = [aws_instance.proxy.public_ip]
}
output "proxy_private_ip" {
  value = [aws_instance.proxy.private_ip]
}
output "private_vm_ips" {
  value = [aws_instance.private_vms.*.private_ip]
}
output "lb_ip" {
  value = [aws_eip.rancher.public_ip]
}
output "dns_name" {
  value = [digitalocean_record.rancher.fqdn]
}