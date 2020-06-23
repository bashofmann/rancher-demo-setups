output "node_ips" {
  value = [vsphere_virtual_machine.k3s-nodes.*.default_ip_address]
}