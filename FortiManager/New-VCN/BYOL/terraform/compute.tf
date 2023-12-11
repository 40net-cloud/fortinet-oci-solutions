resource "oci_core_instance" "FortiManager" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "FortiManager"
  shape               = var.instance_shape

  // Uncomment and addapt if you are yousing newer instance types like VM.Standard.E3.Flex
  #  shape_config {
  #    memory_in_gbs = "16"
  #    ocpus         = "4"
  #  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrust_subnet.id
    display_name     = "FortiManager"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.untrust_private_ip
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true

  timeouts {
    create = "60m"
  }
}