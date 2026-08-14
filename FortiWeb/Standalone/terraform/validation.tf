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
      condition = !local.use_existing_vcn || (
        trimspace(var.vcn_id) != "" &&
        trimspace(var.existing_igw_ocid) != ""
      )
      error_message = "vcn_id and existing_igw_ocid are required when using an existing VCN."
    }

    precondition {
      condition = alltrue([
        tonumber(split("/", var.untrust_subnet_cidr)[1]) >= tonumber(split("/", local.selected_vcn_cidr)[1]),
        tonumber(split("/", var.trust_subnet_cidr)[1]) >= tonumber(split("/", local.selected_vcn_cidr)[1]),
        cidrhost(local.selected_vcn_cidr, 0) == cidrhost("${cidrhost(var.untrust_subnet_cidr, 0)}/${split("/", local.selected_vcn_cidr)[1]}", 0),
        cidrhost(local.selected_vcn_cidr, 0) == cidrhost("${cidrhost(var.trust_subnet_cidr, 0)}/${split("/", local.selected_vcn_cidr)[1]}", 0)
      ])
      error_message = "Both subnet CIDRs must be entirely contained in the selected VCN CIDR."
    }

    precondition {
      condition = !(
        cidrhost(var.untrust_subnet_cidr, 0) == cidrhost("${cidrhost(var.trust_subnet_cidr, 0)}/${split("/", var.untrust_subnet_cidr)[1]}", 0) ||
        cidrhost(var.trust_subnet_cidr, 0) == cidrhost("${cidrhost(var.untrust_subnet_cidr, 0)}/${split("/", var.trust_subnet_cidr)[1]}", 0)
      )
      error_message = "The untrusted and trusted subnet CIDRs must not overlap."
    }

    precondition {
      condition = alltrue([
        cidrhost(var.untrust_subnet_cidr, 0) == cidrhost("${var.fwb_untrust_ip}/${split("/", var.untrust_subnet_cidr)[1]}", 0),
        cidrhost(var.trust_subnet_cidr, 0) == cidrhost("${var.fwb_trust_ip}/${split("/", var.trust_subnet_cidr)[1]}", 0)
      ])
      error_message = "Each FortiWeb interface IP must belong to its corresponding subnet CIDR."
    }

    precondition {
      condition = alltrue([
        !contains([for offset in [0, 1, 2, 3, -1] : cidrhost(var.untrust_subnet_cidr, offset)], var.fwb_untrust_ip),
        !contains([for offset in [0, 1, 2, 3, -1] : cidrhost(var.trust_subnet_cidr, offset)], var.fwb_trust_ip)
      ])
      error_message = "FortiWeb interface IPs cannot use OCI-reserved subnet addresses."
    }
  }
}

