##############################################################################################################
#
# OCI Fortigate HA Single AD deployment
# FortiGate setup with Active/Passice in Single AD
#
##############################################################################################################

##############################################################################################################
# BOOT VOLUME ATTACHEMENTS
##############################################################################################################

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach-a" {
  depends_on          = [oci_core_instance.vm-a]
  availability_domain = oci_core_instance.vm-a.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm-a.id
}

data "oci_core_boot_volume_attachments" "block_attach-b" {
  depends_on          = [oci_core_instance.vm-b]
  availability_domain = oci_core_instance.vm-b.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm-b.id
}

##############################################################################################################
# FORTIGATES
##############################################################################################################

### FGTA
resource "oci_core_instance" "vm-a" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  fault_domain = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_ocid
  display_name        = "vm-a"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.mgmt_subnet.id
    display_name     = "vm-a"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.mgmt_private_ip_primary_a
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid[var.region]

    //for PIC image: source_id   = "${var.vm_image_ocid}"
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
      // ssh_authorized_keys = "${var.ssh_public_key}"
    user_data = base64encode(data.template_file.vm-a_userdata.rendered)
  }

  timeouts {
    create = "60m"
  }
}
# block volumes
resource "oci_core_volume" "vm_volume-a" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-a" {
  attachment_type = "paravirtualized"
  compartment_id  = var.compartment_ocid
  instance_id     = oci_core_instance.vm-a.id
  volume_id       = oci_core_volume.vm_volume-a.id
}

# vnic attachments
resource "oci_core_vnic_attachment" "vnic_attach_untrust_a" {
  depends_on = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a.id
  display_name = "vnic_untrust_a"

  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust_subnet.id
    display_name           = "vnic_untrust_a"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.untrust_private_ip_primary_a
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
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
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
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
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }
}

# config
data "template_file" "vm-a_userdata" {
  template = file("./fgt-userdata.tpl")
  
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
    priority = "250"
    hostname = "FGTA" 
    tenancy_ocid = var.tenancy_ocid
    compartment_ocid = var.compartment_ocid
    sdn_region_ocid = var.region
    sdn_oci_certificate_name = var.sdn_oci_certificate_name
    license_file = file(var.license_vm-a)
  }
}

### FGTB
resource "oci_core_instance" "vm-b" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
   fault_domain = "FAULT-DOMAIN-2"
  compartment_id      = var.compartment_ocid
  display_name        = "vm-b"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.mgmt_subnet.id
    display_name     = "vm-b"
    assign_public_ip = true
    hostname_label   = "vmb"
    private_ip       = var.mgmt_private_ip_primary_b
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }

  source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid[var.region]

    //for PIC image: source_id   = "${var.vm_image_ocid}"

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
      // ssh_authorized_keys = "${var.ssh_public_key}"
      user_data = base64encode(data.template_file.vm-b_userdata.rendered)
    }

  timeouts {
    create = "60m"
  }
}

# blocks
resource "oci_core_volume" "vm_volume-b" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-b"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-b" {
  attachment_type = "paravirtualized"
  compartment_id  = var.compartment_ocid
  instance_id     = oci_core_instance.vm-b.id
  volume_id       = oci_core_volume.vm_volume-b.id
}

# vnic attachments
resource "oci_core_vnic_attachment" "vnic_attach_untrust_b" {
  depends_on = [oci_core_instance.vm-b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "vnic_untrust_b"

  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust_subnet.id
    display_name           = "vnic_untrust_b"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.untrust_private_ip_primary_b
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }
}

resource "oci_core_vnic_attachment" "vnic_attach_trust_b" {
  depends_on = [oci_core_vnic_attachment.vnic_attach_untrust_b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "vnic_trust"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id
    display_name           = "vnic_trust_b"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_b
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }
}

resource "oci_core_vnic_attachment" "vnic_attach_hb_b" {
  depends_on = [oci_core_vnic_attachment.vnic_attach_trust_b]
  instance_id  = oci_core_instance.vm-b.id
  display_name = "vnic_hb_b"

  create_vnic_details {
    subnet_id              = oci_core_subnet.hb_subnet.id
    display_name           = "vnic_hb_b"
    assign_public_ip       = false
    skip_source_dest_check = false
    private_ip             = var.hb_private_ip_primary_b
    nsg_ids = [oci_core_network_security_group.all_network_security_group.id]
  }
}

#config
data "template_file" "vm-b_userdata" {
  template = file("./fgt-userdata.tpl")
  
  vars = {
    mgmt_ip = var.mgmt_private_ip_primary_b
    mgmt_ip_mask = "255.255.255.0"
    untrust_ip = var.untrust_private_ip_primary_b
    untrust_ip_mask = "255.255.255.0"
    trust_ip = var.trust_private_ip_primary_b
    trust_ip_mask = "255.255.255.0"
    hb_ip = var.hb_private_ip_primary_b
    hb_ip_mask = "255.255.255.0"
    hb_peer_ip = var.hb_private_ip_primary_a
    untrust_floating_private_ip = var.untrust_floating_private_ip
    untrust_floating_private_ip_mask = "255.255.255.0"
    trust_floating_private_ip = var.trust_floating_private_ip
    trust_floating_private_ip_mask = "255.255.255.0"
    untrust_subnet_gw = var.untrust_subnet_gateway
    vcn_cidr = var.vcn_cidr
    trust_subnet_gw = var.trust_subnet_gateway
    mgmt_subnet_gw = var.mgmt_subnet_gateway
    hostname = "FGTB"
    priority = "100"
    tenancy_ocid = var.tenancy_ocid
    compartment_ocid = var.compartment_ocid
    sdn_region_ocid = var.region
    sdn_oci_certificate_name = var.sdn_oci_certificate_name
    license_file = file(var.license_vm-b)
  }
}