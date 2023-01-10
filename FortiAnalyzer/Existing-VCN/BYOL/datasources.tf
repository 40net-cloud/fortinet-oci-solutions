# Gets a list of Availability Domains
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number = var.availability_domain
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach" {
  depends_on          = [oci_core_instance.FortiAnalyzer]
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.FortiAnalyzer.id
}