output "fortianalyzer_vm_a_public_ip" {
  description = "Public IP address of FortiAnalyzer VM"
  value       = oci_core_instance.vm-a[0].public_ip
}