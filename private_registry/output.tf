output "node_ips" {
  value = aws_instance.vmlb.*.public_ip
}

output "lb" {
  value = aws_elb.rancher-server-lb.dns_name
}

output "dns" {
  value = digitalocean_record.wildcard.fqdn
}

output "reglb" {
  value = aws_elb.registry-server-lb.dns_name
}

output "regdns" {
  value = digitalocean_record.registry.fqdn
}