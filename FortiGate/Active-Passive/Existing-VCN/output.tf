# Output the private and public IPs of the instance

output "Mgmt-FortiGate-A-PublicIP" {
  value = [oci_core_instance.FortiGate-A.*.public_ip]
}

output "FortiGate-A-ID" {
  value = [oci_core_instance.FortiGate-A.id]
}

output "Mgmt-FortiGate-B-PublicIP" {
  value = [oci_core_instance.FortiGate-B.*.public_ip]
}

output "FortiGate-B-ID" {
  value = [oci_core_instance.FortiGate-B.id]
}