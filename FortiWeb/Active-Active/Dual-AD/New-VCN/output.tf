##############################################################################################################
#
# DRGv2 Hub and Spoke traffic inspection
# FortiGate Active/Active Load Balanced pair of standalone FortiGate VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

//  Default Username and Password
output "Default_Username" {
  value = "admin"
}
output "Default_Password_FWB_A" {
  value = oci_core_instance.vm_fwb_a.id
}
output "Default_Password_FWB_B" {
  value = oci_core_instance.vm_fwb_b.id
}

// FortiGate A
output "fwbAMGMTPublicIP" {
  value = oci_core_instance.vm_fwb_a.*.public_ip
}

// FortiGate B
output "fwbBMGMTPublicIP" {
  value = oci_core_instance.vm_fwb_b.*.public_ip
}
