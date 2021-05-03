output "node_ips" {
  value = aws_instance.vmlb.*.public_ip
}

output "rancher_lb" {
  value = aws_elb.rancher-server-lb.dns_name
}

output "rancher_dns" {
  value = digitalocean_record.rancher.fqdn
}

output "keycloak_dns" {
  value = digitalocean_record.keycloak.fqdn
}

output "kubernetes_lb" {
  value = aws_elb.kubernetes-lb.dns_name
}

output "kubernetes_dns" {
  value = digitalocean_record.kubernetes.fqdn
}