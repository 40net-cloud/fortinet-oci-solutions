# Output the private and public IPs of the instance

output "Mgmt-FortiGate-PublicIP" {
  value = [oci_core_instance.FortiGate.*.public_ip]
}

output "FortiGate-ID" {
  value = [oci_core_instance.FortiGate.id]
}