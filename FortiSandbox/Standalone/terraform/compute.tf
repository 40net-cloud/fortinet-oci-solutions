resource "oci_core_instance" "fortisandbox" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    oci_core_app_catalog_subscription.fortisandbox
  ]

  availability_domain = var.availability_domain_name != "" ? var.availability_domain_name : data.oci_identity_availability_domains.ads.availability_domains[0].name
  fault_domain        = var.fault_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  create_vnic_details {
    subnet_id        = local.selected_front_subnet_id
    display_name     = "${var.vm_display_name}-port1"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "fortisandbox"
    private_ip       = trimspace(var.frontend_private_ip) != "" ? trimspace(var.frontend_private_ip) : null
    nsg_ids          = [oci_core_network_security_group.frontend.id]
  }

  launch_options {
    network_type = "PARAVIRTUALIZED"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_listing_resource_version.fortisandbox[0].listing_resource_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  timeouts {
    create = "60m"
  }
}
