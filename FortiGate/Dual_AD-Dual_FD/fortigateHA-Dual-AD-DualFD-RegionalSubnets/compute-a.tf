resource "oci_core_instance" "vm-a" {
  availability_domain = data.oci_identity_availability_domain.ad-a.name
  compartment_id      = var.compartment_ocid
  display_name        = "vm-a"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.mgmt_subnet.id
    display_name     = "vm-a"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.mgmt_private_ip_primary_a
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
      user_data           = base64encode(data.template_file.vm-a_userdata.rendered)
    }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_vnic_attachment" "vnic_attach_untrust_a" {
  depends_on = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "vnic_untrust_a"

  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust_subnet.id
    display_name           = "vnic_untrust_a"
    assign_public_ip       = false
    skip_source_dest_check = false
    private_ip             = var.untrust_private_ip_primary_a
  }
}

resource "oci_core_private_ip" "untrust_private_ip" {
  #Get Primary VNIC id
  vnic_id = element(oci_core_vnic_attachment.vnic_attach_untrust_a.*.vnic_id, 0)

  #Optional	
  display_name   = "untrust_ip"
  hostname_label = "untrust"
  ip_address     = var.untrust_floating_private_ip
}

resource "oci_core_public_ip" "untrust_public_ip" {
  #Required
  compartment_id = var.compartment_ocid
  lifetime       = var.untrust_public_ip_lifetime

  #Optional    
  display_name  = "vm-untrust"
  private_ip_id = oci_core_private_ip.untrust_private_ip.id
}

resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  depends_on = [oci_core_vnic_attachment.vnic_attach_untrust_a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "vnic_trust"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id
    display_name           = "vnic_trust_a"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_a
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  #Get Primary VNIC id
  vnic_id = element(oci_core_vnic_attachment.vnic_attach_trust_a.*.vnic_id, 0)

  #Optional	
  display_name   = "trust_ip"
  hostname_label = "trust"
  ip_address     = var.trust_floating_private_ip
}


resource "oci_core_vnic_attachment" "vnic_attach_hb_a" {
  depends_on = [oci_core_vnic_attachment.vnic_attach_trust_a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "vnic_hb_a"

  create_vnic_details {
    subnet_id              = oci_core_subnet.hb_subnet.id
    display_name           = "vnic_hb_a"
    assign_public_ip       = false
    skip_source_dest_check = false
    private_ip             = var.hb_private_ip_primary_a
  }
}


data "template_file" "vm-a_userdata" {

  template = file(var.bootstrap_vm-a)
  
  vars = {
    mgmt_ip = var.mgmt_private_ip_primary_a
    mgmt_ip_mask = "255.255.255.0"
    untrust_ip = var.untrust_private_ip_primary_a
    untrust_ip_mask = "255.255.255.0"
    trust_ip = var.trust_private_ip_primary_a
    trust_ip_mask = "255.255.255.0"
    hb_ip = var.hb_private_ip_primary_a
    hb_ip_mask = "255.255.255.0"
    hb_peer_ip = var.hb_private_ip_primary_b
    untrust_floating_private_ip = var.untrust_floating_private_ip
    untrust_floating_private_ip_mask = "255.255.255.0"
    trust_floating_private_ip = var.trust_floating_private_ip
    trust_floating_private_ip_mask = "255.255.255.0"
    untrust_subnet_gw = var.untrust_subnet_gateway
    vcn_cidr = var.vcn_cidr
    trust_subnet_gw = var.trust_subnet_gateway
    mgmt_subnet_gw = var.mgmt_subnet_gateway
    
    tenancy_ocid = var.tenancy_ocid
    //oci_user_ocid = var.oci_user_ocid
    compartment_ocid = var.compartment_ocid
  
    license_file_a = file(var.license_vm-a)

  }
}
