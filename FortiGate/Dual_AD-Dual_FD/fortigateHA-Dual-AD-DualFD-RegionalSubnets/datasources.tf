# Gets a list of Availability Domains
data "oci_identity_availability_domain" "ad-a" {
  compartment_id = var.tenancy_ocid
  ad_number = var.availability_domain-a
}

data "oci_identity_availability_domain" "ad-b" {
  compartment_id = var.tenancy_ocid
  ad_number = var.availability_domain-b
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach-a" {
  depends_on          = [oci_core_instance.vm-a]
  availability_domain = data.oci_identity_availability_domain.ad-a.name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm-a.id
}

data "oci_core_boot_volume_attachments" "block_attach-b" {
  depends_on          = [oci_core_instance.vm-b]
  availability_domain = data.oci_identity_availability_domain.ad-b.name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm-b.id
}
