resource "oci_core_instance" "fortiweb" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    terraform_data.validate_marketplace_package,
    terraform_data.validate_network,
    oci_core_app_catalog_subscription.fortiweb
  ]

  availability_domain = var.availability_domain_name
  fault_domain        = var.fault_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = var.prefix
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
    display_name     = "${var.prefix}-port1"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "fortiweb"
    private_ip       = var.fwb_untrust_ip
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
    user_data = base64encode(templatefile("${path.module}/customdatafwb.tpl", {
      fwb_vm_name          = var.prefix
      untrusted_gateway_ip = oci_core_subnet.untrust.virtual_router_ip
      fwb_ipaddress_port2  = var.fwb_trust_ip
      trust_mask           = cidrnetmask(var.trust_subnet_cidr)
    }))
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_vnic_attachment" "fortiweb_trust" {
  count = length(oci_core_instance.fortiweb)

  instance_id  = oci_core_instance.fortiweb[0].id
  display_name = "${var.prefix}-port2"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust.id
    display_name           = "${var.prefix}-port2"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fwb_trust_ip
  }
}

resource "oci_core_volume" "fortiweb" {
  count = length(oci_core_instance.fortiweb)

  availability_domain = var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = "${var.prefix}-data"
  size_in_gbs         = var.data_volume_size_in_gbs
}

resource "oci_core_volume_attachment" "fortiweb" {
  count = length(oci_core_volume.fortiweb)

  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.fortiweb[0].id
  volume_id       = oci_core_volume.fortiweb[0].id
}

