output "node_ips" {
  value = aws_instance.k8sdemo-vm.*.public_ip
}

output "rancher_lb" {
  value = aws_elb.k8sdemo-lb.dns_name
}

output "rancher_dns" {
  value = digitalocean_record.rancher.fqdn
}
