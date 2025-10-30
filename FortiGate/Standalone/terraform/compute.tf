########################################
###### Create FortiGate VM #####
########################################

resource "oci_core_instance" "vm-a" {
  count               = local.matched_package != null ? 1 : 0
  availability_domain = (var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "FortiGate-Standalone-Firewall"
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = local.vm_compute_shape != null && contains([
      "VM.Standard.A1.Flex",
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex", # ← NEW
      "VM.Standard.E6.Flex"  # ← NEW
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
    private_ip       = var.mgmt_private_ip
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
##### trust VNIC-A #####
##########################
resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  count        = 1
  depends_on   = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a[0].id
  display_name = "vnic_trust_a"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
    display_name           = "vnic_trust_a"
    assign_public_ip       = false
    skip_source_dest_check = false
    // private_ip             = var.trust_private_ip   // removed to avoid duplicate allocation
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  vnic_id        = oci_core_vnic_attachment.vnic_attach_trust_a[0].vnic_id
  display_name   = "trust_ip"
  hostname_label = "trust"
  ip_address     = var.trust_private_ip
}

resource "oci_core_public_ip" "trust_public_ip" {
  compartment_id = var.compute_compartment_ocid
  lifetime       = var.trust_public_ip_lifetime
  display_name   = "vm-trust"
  private_ip_id  = oci_core_private_ip.trust_private_ip.id
}

###############################
##### FortiGate Bootstrap #####
###############################
data "template_file" "vm-a_userdata" {
  template = file(var.bootstrap_vm-a)
  vars = {
    mgmt_ip          = var.mgmt_private_ip
    mgmt_ip_mask     = "255.255.255.0"
    trust_ip         = var.trust_private_ip
    trust_ip_mask    = "255.255.255.0"
    trust_subnet_gw  = var.trust_subnet_gateway
    vcn_cidr         = var.vcn_cidr_block
    mgmt_subnet_gw   = var.mgmt_subnet_gateway
    tenancy_ocid     = var.tenancy_ocid
    compartment_ocid = var.compute_compartment_ocid
  }
}

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