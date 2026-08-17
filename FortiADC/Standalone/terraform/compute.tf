resource "oci_core_instance" "fortiadc" {
  count = local.matched_package != null ? 1 : 0

  depends_on = [
    terraform_data.validate_configuration,
    oci_core_app_catalog_subscription.fortiadc
  ]

  availability_domain = var.availability_domain_name
  fault_domain        = var.fault_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  create_vnic_details {
    subnet_id        = local.selected_front_subnet_id
    display_name     = "${var.vm_display_name}-port1"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "fortiadc"
    private_ip       = var.frontend_private_ip
    nsg_ids          = [oci_core_network_security_group.frontend.id]
  }

  launch_options {
    network_type = "PARAVIRTUALIZED"
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_app_catalog_listing_resource_version.fortiadc[0].listing_resource_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  //  metadata = {
  //    user_data = base64encode(templatefile("${path.module}/cloudinit/bootstrap.tpl", {
  //      hostname        = var.vm_display_name
  //      backend_ip      = var.backend_private_ip
  //      backend_netmask = cidrnetmask(var.backend_subnet_cidr)
  //    }))
  //  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_vnic_attachment" "backend" {
  count = length(oci_core_instance.fortiadc)

  instance_id  = oci_core_instance.fortiadc[0].id
  display_name = "${var.vm_display_name}-port2"

  create_vnic_details {
    subnet_id              = local.selected_back_subnet_id
    display_name           = "${var.vm_display_name}-port2"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.backend_private_ip
    nsg_ids                = [oci_core_network_security_group.backend.id]
  }
}
