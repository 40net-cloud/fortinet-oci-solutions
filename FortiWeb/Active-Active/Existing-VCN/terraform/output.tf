##############################################################################################################
#
# FortiWeb Active/Active Load Balanced pair of standalone FortiWeb VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

//  Default Username and Password
output "Default_Username" {
  value = "admin"
}
output "Default_Password_FortiWeb_A" {
  value = oci_core_instance.vm_fwb_a.id
}
output "Default_Password_FortiWeb_B" {
  value = oci_core_instance.vm_fwb_b.id
}

// FortiGate A
output "FortiWeb_A_Management_IP" {
  value = oci_core_instance.vm_fwb_a.*.public_ip
}

// FortiGate B
output "FortiWeb_B_Management_IP" {
  value = oci_core_instance.vm_fwb_b.*.public_ip
}
