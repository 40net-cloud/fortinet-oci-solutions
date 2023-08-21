##############################################################################################################
#
# FortiWeb Active/Active Load Balanced pair of standalone FortiWeb VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach_fwb_a" {
  depends_on          = [oci_core_instance.vm_fwb_a]
  availability_domain = oci_core_instance.vm_fwb_a.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_fwb_a.id
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach_fwb_b" {
  depends_on          = [oci_core_instance.vm_fwb_b]
  availability_domain = oci_core_instance.vm_fwb_b.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_fwb_b.id
}