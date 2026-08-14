resource "oci_core_instance" "fwba" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    terraform_data.validate_marketplace_package,
    terraform_data.validate_network,
    oci_core_app_catalog_subscription.fortiweb
  ]

  availability_domain = var.availability_domain_name_a
  fault_domain        = var.fault_domain_name_a
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-A"
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = contains(local.flex_shapes, local.vm_compute_shape) ? [1] : []

    content {
      ocpus         = var.ocpu_count
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrust.id
    display_name     = "${var.prefix}-A-port1"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "fwba"
    private_ip       = var.fwba_untrust_ip
  }

  launch_options {
    network_type = "PARAVIRTUALIZED"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_listing_resource_version.fortiweb[0].listing_resource_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    user_data = base64encode(templatefile("${path.module}/customdatafwba.tpl", {
      fwba_vm_name         = "${var.prefix}-A"
      untrusted_gateway_ip = oci_core_subnet.untrust.virtual_router_ip
      fwba_ipaddress_port2 = var.fwba_trust_ip
      fwbb_ipaddress_port2 = var.fwbb_trust_ip
      trust_mask           = cidrnetmask(var.trust_subnet_cidr)
    }))
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_instance" "fwbb" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    terraform_data.validate_marketplace_package,
    terraform_data.validate_network,
    oci_core_app_catalog_subscription.fortiweb
  ]

  availability_domain = var.availability_domain_name_b
  fault_domain        = var.fault_domain_name_b
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-B"
  shape               = local.vm_compute_shape

  dynamic "shape_config" {
    for_each = contains(local.flex_shapes, local.vm_compute_shape) ? [1] : []

    content {
      ocpus         = var.ocpu_count
      memory_in_gbs = var.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrust.id
    display_name     = "${var.prefix}-B-port1"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "fwbb"
    private_ip       = var.fwbb_untrust_ip
  }

  launch_options {
    network_type = "PARAVIRTUALIZED"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_listing_resource_version.fortiweb[0].listing_resource_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    user_data = base64encode(templatefile("${path.module}/customdatafwbb.tpl", {
      fwbb_vm_name         = "${var.prefix}-B"
      untrusted_gateway_ip = oci_core_subnet.untrust.virtual_router_ip
      fwbb_ipaddress_port2 = var.fwbb_trust_ip
      fwba_ipaddress_port2 = var.fwba_trust_ip
      trust_mask           = cidrnetmask(var.trust_subnet_cidr)
    }))
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_vnic_attachment" "fwba_trust" {
  count = length(oci_core_instance.fwba)

  instance_id  = oci_core_instance.fwba[0].id
  display_name = "${var.prefix}-A-port2"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust.id
    display_name           = "${var.prefix}-A-port2"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fwba_trust_ip
  }
}

resource "oci_core_vnic_attachment" "fwbb_trust" {
  count = length(oci_core_instance.fwbb)

  instance_id  = oci_core_instance.fwbb[0].id
  display_name = "${var.prefix}-B-port2"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust.id
    display_name           = "${var.prefix}-B-port2"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fwbb_trust_ip
  }
}

resource "oci_core_volume" "fwba" {
  count = length(oci_core_instance.fwba)

  availability_domain = var.availability_domain_name_a
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-A-data"
  size_in_gbs         = var.data_volume_size_in_gbs
}

resource "oci_core_volume" "fwbb" {
  count = length(oci_core_instance.fwbb)

  availability_domain = var.availability_domain_name_b
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-B-data"
  size_in_gbs         = var.data_volume_size_in_gbs
}

resource "oci_core_volume_attachment" "fwba" {
  count = length(oci_core_volume.fwba)

  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.fwba[0].id
  volume_id       = oci_core_volume.fwba[0].id
}

resource "oci_core_volume_attachment" "fwbb" {
  count = length(oci_core_volume.fwbb)

  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.fwbb[0].id
  volume_id       = oci_core_volume.fwbb[0].id
}
