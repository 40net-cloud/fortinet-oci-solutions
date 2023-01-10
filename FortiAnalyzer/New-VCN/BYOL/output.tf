# Output the private and public IPs of the instance

output "Mgmt-FortiAnalyzer-PublicIP" {
  value = [oci_core_instance.FortiAnalyzer.*.public_ip]
}

output "FortiAnalyzer-ID" {
  value = [oci_core_instance.FortiAnalyzer.id]
}