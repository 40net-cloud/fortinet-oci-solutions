# Output the private and public IPs of the instance

output "Mgmt-VM-A-PublicIP" {
  value = [oci_core_instance.vm-a.*.public_ip]
}

output "VM-A-ID" {
  value = [oci_core_instance.vm-a.id]
}


output "Mgmt-VM-B-PublicIP" {
  value = [oci_core_instance.vm-b.*.public_ip]
}

output "VM-B-ID" {
  value = [oci_core_instance.vm-b.id]
}