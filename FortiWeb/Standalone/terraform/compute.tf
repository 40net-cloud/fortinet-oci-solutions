resource "oci_core_instance" "vm-a" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    oci_core_app_catalog_subscription.fortiweb
  ]

  availability_domain = var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : data.oci_identity_availability_domains.ads.availability_domains[0].name
  fault_domain        = var.fault_domain_name_1
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = contains([
      "VM.Standard3.Flex",
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex"
    ], local.vm_compute_shape) ? [1] : []

    content {
      ocpus         = var.ocpu_count
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.management_subnet_id : oci_core_subnet.management_subnet[0].id
    display_name     = "vm-a-mgmt"
    assign_public_ip = true
    hostname_label   = "fwbmgmt"
    private_ip       = var.mgmt_private_ip
  }

  launch_options {
    network_type = var.instance_launch_options_network_type
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_listing_resource_version.fortiweb[0].listing_resource_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  count        = local.matched_package != null ? 1 : 0
  depends_on   = [oci_core_instance.vm-a]
  instance_id  = oci_core_instance.vm-a[0].id
  display_name = "vnic_trust_a"

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
    display_name           = "vnic_trust_a"
    assign_public_ip       = false
    skip_source_dest_check = false
  }
  timeouts {
    delete = "6m"
  }
}

resource "oci_core_private_ip" "trust_private_ip" {
  count = local.matched_package != null ? 1 : 0

  vnic_id        = oci_core_vnic_attachment.vnic_attach_trust_a[0].vnic_id
  display_name   = "trust_ip"
  hostname_label = "trust"
  ip_address     = var.trust_private_ip
}

resource "oci_core_volume" "vm_volume_a" {
  count               = local.matched_package != null ? 1 : 0
  availability_domain = var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach_a" {
  count           = length(oci_core_instance.vm-a) > 0 ? 1 : 0
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm-a[0].id
  volume_id       = oci_core_volume.vm_volume_a[count.index].id
}
