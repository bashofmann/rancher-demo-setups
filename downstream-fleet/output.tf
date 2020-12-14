output "node_ips" {
  value = [
    aws_instance.amd_vms.*.public_ip,
    aws_instance.arm_vms.*.public_ip
  ]
}