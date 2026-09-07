resource "terraform_data" "validate_marketplace_package" {
  lifecycle {
    precondition {
      condition = (
        local.normalized_cpu_type == "X64" &&
        length(local.matched_packages) == 1
      )
      error_message = format(
        "Expected exactly one X64 FortiWeb Marketplace package but found %d. Check license_type, fortiweb_version, and final_listings.json.",
        length(local.matched_packages)
      )
    }

    precondition {
      condition = local.matched_package == null ? true : contains(
        data.oci_core_app_catalog_listing_resource_version.fortiweb[0].compatible_shapes,
        local.vm_compute_shape
      )
      error_message = "The selected FortiWeb Marketplace image does not support the selected compute shape in this region."
    }
  }
}

resource "terraform_data" "validate_network" {
  lifecycle {
    precondition {
      condition = !local.use_existing_network || (
        trimspace(var.vcn_id) != "" &&
        trimspace(var.lb_subnet_id) != "" &&
        trimspace(var.untrust_subnet_id) != ""
      )
      error_message = "vcn_id, lb_subnet_id, and untrust_subnet_id are required when using existing networking."
    }

    precondition {
      condition = local.use_existing_network || alltrue([
        tonumber(split("/", var.lb_subnet_cidr)[1]) >= tonumber(split("/", local.selected_vcn_cidr)[1]),
        tonumber(split("/", var.untrust_subnet_cidr)[1]) >= tonumber(split("/", local.selected_vcn_cidr)[1]),
        cidrhost(local.selected_vcn_cidr, 0) == cidrhost("${cidrhost(var.lb_subnet_cidr, 0)}/${split("/", local.selected_vcn_cidr)[1]}", 0),
        cidrhost(local.selected_vcn_cidr, 0) == cidrhost("${cidrhost(var.untrust_subnet_cidr, 0)}/${split("/", local.selected_vcn_cidr)[1]}", 0)
      ])
      error_message = "The new NLB and FortiWeb subnet CIDRs must be entirely contained in the selected VCN CIDR."
    }

    precondition {
      condition = local.use_existing_network || alltrue([
        !(
          cidrhost(var.lb_subnet_cidr, 0) == cidrhost("${cidrhost(var.untrust_subnet_cidr, 0)}/${split("/", var.lb_subnet_cidr)[1]}", 0) ||
          cidrhost(var.untrust_subnet_cidr, 0) == cidrhost("${cidrhost(var.lb_subnet_cidr, 0)}/${split("/", var.untrust_subnet_cidr)[1]}", 0)
        )
      ])
      error_message = "The NLB and FortiWeb subnet CIDRs must not overlap."
    }

    precondition {
      condition = alltrue([
        cidrhost(local.selected_untrust_subnet_cidr, 0) == cidrhost("${var.fwba_untrust_ip}/${split("/", local.selected_untrust_subnet_cidr)[1]}", 0),
        cidrhost(local.selected_untrust_subnet_cidr, 0) == cidrhost("${var.fwbb_untrust_ip}/${split("/", local.selected_untrust_subnet_cidr)[1]}", 0)
      ])
      error_message = "Each FortiWeb port1 IP must belong to the selected FortiWeb subnet CIDR."
    }

    precondition {
      condition = alltrue([
        var.fwba_untrust_ip != var.fwbb_untrust_ip,
        !contains([for offset in [0, 1, 2, 3, -1] : cidrhost(local.selected_untrust_subnet_cidr, offset)], var.fwba_untrust_ip),
        !contains([for offset in [0, 1, 2, 3, -1] : cidrhost(local.selected_untrust_subnet_cidr, offset)], var.fwbb_untrust_ip)
      ])
      error_message = "FortiWeb member IPs must be unique and cannot use OCI-reserved subnet addresses."
    }
  }
}
