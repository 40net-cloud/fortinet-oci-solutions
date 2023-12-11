resource "oci_core_instance" "FortiGate" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "FortiGate"
  shape               = var.instance_shape

  // Uncomment and addapt if you are yousing newer instance types like VM.Standard.E3.Flex
  #  shape_config {
  #    memory_in_gbs = "16"
  #    ocpus         = "4"
  #  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrust_subnet.id
    display_name     = "FortiGate"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.untrust_private_ip
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid

    //for PIC image: source_id   = var.vm_image_ocid

    # Apply this to set the size of the boot volume that's created for this instance.
    # Otherwise, the default boot volume size of the image is used.
    # This should only be specified when source_type is set to "image".
    #boot_volume_size_in_gbs = "60"
  }

  # Apply the following flag only if you wish to preserve the attached boot volume upon destroying this instance
  # Setting this and destroying the instance will result in a boot volume that should be managed outside of this config.
  # When changing this value, make sure to run 'terraform apply' so that it takes effect before the resource is destroyed.
  #preserve_boot_volume = true


  //required for metadata setup via cloud-init
  metadata = {
    // ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(data.template_file.FortiGate_userdata.rendered)
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_public_ip" "untrust_public_ip" {
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = var.untrust_public_ip_lifetime

}

resource "oci_core_vnic_attachment" "vnic_attach_trust" {
  depends_on   = [oci_core_instance.FortiGate]
  instance_id  = oci_core_instance.FortiGate.id
  display_name = "vnic_trust"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id
    display_name           = "vnic_trust"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  #Get Primary VNIC id
  vnic_id = element(oci_core_vnic_attachment.vnic_attach_trust.*.vnic_id, 0)

}

data "template_file" "FortiGate_userdata" {

  template = file(var.bootstrap_FortiGate)

  vars = {
    untrust_ip        = var.untrust_private_ip
    untrust_ip_mask   = "255.255.255.0"
    trust_ip          = var.trust_private_ip
    trust_ip_mask     = "255.255.255.0"
    untrust_subnet_gw = var.untrust_subnet_gateway
    trust_subnet_gw   = var.trust_subnet_gateway
    vcn_cidr          = var.vcn_cidr

    tenancy_ocid     = var.tenancy_ocid
    compartment_ocid = var.compartment_ocid
  }
}