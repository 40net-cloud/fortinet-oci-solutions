# Output the private and public IPs of the instance

output "Mgmt-FortiManager-PublicIP" {
  value = [oci_core_instance.FortiManager.*.public_ip]
}

output "FortiManager-ID" {
  value = [oci_core_instance.FortiManager.id]
}