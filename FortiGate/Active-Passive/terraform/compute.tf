########################################
###### Create FortiGate Primary VM #####
########################################

resource "oci_core_instance" "vm-a" {
  count               = local.matched_package != null ? 1 : 0
  availability_domain = (var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "FortiGate-Primary-Firewall"
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = local.vm_compute_shape != null && contains([
      "VM.Standard.A1.Flex",
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex",
      "VM.Standard.E6.Flex",
      "VM.Standard3.Flex"
    ], local.vm_compute_shape) ? [1] : []

    content {
      ocpus         = var.ocpu_count
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.management_subnet_id : oci_core_subnet.management_subnet[0].id
    display_name     = "vm-a"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.mgmt_private_ip_primary_a
  }

  source_details {
    source_type = "image"
    source_id   = var.license_type == "BYOL" ? local.matched_package.image_id : local.paygo_image_id
  }
  metadata = {
    //ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(data.template_file.vm-a_userdata.rendered)
  }

  timeouts {
    create = "60m"
  }
}

##########################
##### Untrust VNIC-A #####
##########################
resource "oci_core_vnic_attachment" "vnic_attach_untrust_a" {
  count        = 1
  depends_on   = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a[0].id
  display_name = "vnic_untrust_a"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust_subnet[0].id
    display_name           = "vnic_untrust_a"
    assign_public_ip       = true
    skip_source_dest_check = false
    private_ip             = var.untrust_private_ip_primary_a
  }
}

resource "oci_core_private_ip" "untrust_private_ip" {
  vnic_id        = data.oci_core_vnic_attachments.untrust_attachments.vnic_attachments.0.vnic_id
  display_name   = "untrust_ip"
  hostname_label = "untrust"
  ip_address     = var.untrust_floating_private_ip
}

resource "oci_core_public_ip" "untrust_public_ip" {
  compartment_id = var.compute_compartment_ocid
  lifetime       = var.untrust_public_ip_lifetime
  display_name   = "vm-untrust"
  private_ip_id  = oci_core_private_ip.untrust_private_ip.id
}

########################
##### Trust VNIC-A #####
########################
resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_untrust_a]
  count        = 1
  instance_id  = oci_core_instance.vm-a[count.index].id
  display_name = "vnic_trust"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
    display_name           = "vnic_trust_a"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_a
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  vnic_id        = data.oci_core_vnic_attachments.trust_attachments.vnic_attachments.0.vnic_id
  display_name   = "trust_ip"
  hostname_label = "trust"
  ip_address     = var.trust_floating_private_ip
}

##########################
##### HA/Sync VNIC-A #####
##########################
resource "oci_core_vnic_attachment" "vnic_attach_hb_a" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_trust_a]
  count        = 1
  instance_id  = oci_core_instance.vm-a[count.index].id
  display_name = "vnic_hb_a"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.ha_subnet_id : oci_core_subnet.ha_subnet[0].id
    display_name           = "vnic_hb_a"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.hb_private_ip_primary_a
  }
}

#######################################
##### Primary FortiGate Bootstrap #####
#######################################
data "template_file" "vm-a_userdata" {
  template = file(var.bootstrap_vm-a)
  vars = {
    mgmt_ip                          = var.mgmt_private_ip_primary_a
    mgmt_ip_mask                     = "255.255.255.0"
    untrust_ip_a                     = var.untrust_private_ip_primary_a
    untrust_ip_a_mask                = "255.255.255.0"
    trust_ip_a                       = var.trust_private_ip_primary_a
    trust_ip_a_mask                  = "255.255.255.0"
    hb_ip                            = var.hb_private_ip_primary_a
    hb_ip_mask                       = "255.255.255.0"
    hb_peer_ip                       = var.hb_private_ip_primary_b
    untrust_floating_private_ip      = var.untrust_floating_private_ip
    untrust_floating_private_ip_mask = "255.255.255.0"
    trust_floating_private_ip        = var.trust_floating_private_ip
    trust_floating_private_ip_mask   = "255.255.255.0"
    untrust_subnet_gw                = var.untrust_subnet_gateway
    vcn_cidr                         = var.vcn_cidr_block
    trust_subnet_gw                  = var.trust_subnet_gateway
    mgmt_subnet_gw                   = var.mgmt_subnet_gateway
    tenancy_ocid                     = var.tenancy_ocid
    compartment_ocid                 = var.compute_compartment_ocid
  }
}

#######################################
##### Primary FortiGate Volumes #####
#######################################

resource "oci_core_volume" "vm_volume-a" {
  count               = 1
  availability_domain = (var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-a" {
  count           = length(oci_core_instance.vm-a) > 0 ? 1 : 0
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm-a[0].id
  volume_id       = oci_core_volume.vm_volume-a[count.index].id
}

##########################################
###### Create FortiGate Secondary VM #####
##########################################
resource "oci_core_instance" "vm-b" {
  depends_on          = [oci_core_subnet.ha_subnet]
  count               = local.matched_package != null ? 1 : 0
  availability_domain = (var.availability_domain_name_2 != "" ? var.availability_domain_name_2 : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "FortiGate-Secondary-Firewall"
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = local.vm_compute_shape != null && contains([
      "VM.Standard.A1.Flex",
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex",
      "VM.Standard.E6.Flex",
      "VM.Standard3.Flex"
    ], local.vm_compute_shape) ? [1] : []

    content {
      ocpus         = var.ocpu_count
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.management_subnet_id : oci_core_subnet.management_subnet[0].id
    display_name     = "vm-b"
    assign_public_ip = true
    hostname_label   = "vmb"
    private_ip       = var.mgmt_private_ip_primary_b
  }

  source_details {
    source_type = "image"
    source_id   = var.license_type == "BYOL" ? local.matched_package.image_id : local.paygo_image_id
  }
  metadata = {
    //ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(data.template_file.vm-b_userdata.rendered)
  }

  timeouts {
    create = "60m"
  }
}

##########################
##### Untrust VNIC-B #####
##########################
resource "oci_core_vnic_attachment" "vnic_attach_untrust_b" {
  depends_on   = [oci_core_instance.vm-b]
  count        = 1
  instance_id  = oci_core_instance.vm-b[0].id
  display_name = "vnic_untrust_b"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust_subnet[0].id
    display_name           = "vnic_untrust_b"
    assign_public_ip       = true
    skip_source_dest_check = false
    private_ip             = var.untrust_private_ip_primary_b
  }
}

########################
##### Trust VNIC-B #####
########################
resource "oci_core_vnic_attachment" "vnic_attach_trust_b" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_untrust_b]
  count        = 1
  instance_id  = oci_core_instance.vm-b[count.index].id
  display_name = "vnic_trust"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
    display_name           = "vnic_trust_b"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.trust_private_ip_primary_b
  }
}

##########################
##### HA/Sync VNIC-B #####
##########################
resource "oci_core_vnic_attachment" "vnic_attach_hb_b" {
  depends_on   = [oci_core_vnic_attachment.vnic_attach_trust_b]
  count        = 1
  instance_id  = oci_core_instance.vm-b[count.index].id
  display_name = "vnic_hb_b"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.ha_subnet_id : oci_core_subnet.ha_subnet[0].id
    display_name           = "vnic_hb_b"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.hb_private_ip_primary_b
  }
}

#########################################
##### Secondary FortiGate Bootstrap #####
#########################################
data "template_file" "vm-b_userdata" {
  template = file(var.bootstrap_vm-b)

  vars = {
    mgmt_ip                          = var.mgmt_private_ip_primary_b
    mgmt_ip_mask                     = "255.255.255.0"
    untrust_ip_b                     = var.untrust_private_ip_primary_b
    untrust_ip_b_mask                = "255.255.255.0"
    trust_ip_b                       = var.trust_private_ip_primary_b
    trust_ip_b_mask                  = "255.255.255.0"
    hb_ip                            = var.hb_private_ip_primary_b
    hb_ip_mask                       = "255.255.255.0"
    hb_peer_ip                       = var.hb_private_ip_primary_a
    untrust_floating_private_ip      = var.untrust_floating_private_ip
    untrust_floating_private_ip_mask = "255.255.255.0"
    trust_floating_private_ip        = var.trust_floating_private_ip
    trust_floating_private_ip_mask   = "255.255.255.0"
    untrust_subnet_gw                = var.untrust_subnet_gateway
    vcn_cidr                         = var.vcn_cidr_block
    trust_subnet_gw                  = var.trust_subnet_gateway
    mgmt_subnet_gw                   = var.mgmt_subnet_gateway
    tenancy_ocid                     = var.tenancy_ocid
    compartment_ocid                 = var.compute_compartment_ocid
  }
}

#######################################
##### Secondary FortiGate Volumes #####
#######################################

resource "oci_core_volume" "vm_volume-b" {
  count               = 1
  availability_domain = (var.availability_domain_name_2 != "" ? var.availability_domain_name_2 : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "vm_volume-b"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-b" {
  count           = length(oci_core_instance.vm-b) > 0 ? 1 : 0
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm-b[0].id
  volume_id       = oci_core_volume.vm_volume-b[count.index].id
}