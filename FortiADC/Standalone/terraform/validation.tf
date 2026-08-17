resource "terraform_data" "validate_configuration" {
  lifecycle {
    precondition {
      condition     = length(local.matched_packages) == 1
      error_message = "Expected exactly one FortiADC BYOL Marketplace package for the selected version."
    }

    precondition {
      condition = local.matched_package == null ? true : contains(
        data.oci_core_app_catalog_listing_resource_version.fortiadc[0].compatible_shapes,
        var.vm_compute_shape
      )
      error_message = "The FortiADC Marketplace image does not support the selected shape in this region."
    }

    precondition {
      condition     = !local.use_existing_vcn || trimspace(var.vcn_id) != ""
      error_message = "vcn_id is required when reusing an existing VCN."
    }

    precondition {
      condition = !local.use_existing_network || alltrue([
        trimspace(var.frontend_subnet_id) != "",
        trimspace(var.backend_subnet_id) != ""
      ])
      error_message = "frontend_subnet_id and backend_subnet_id are required when using existing VCN and subnets."
    }

    precondition {
      condition     = var.client_port_min <= var.client_port_max
      error_message = "client_port_min must be less than or equal to client_port_max."
    }

    precondition {
      condition = alltrue([
        cidrhost(var.frontend_subnet_cidr, 0) == cidrhost("${var.frontend_private_ip}/${split("/", var.frontend_subnet_cidr)[1]}", 0),
        cidrhost(var.backend_subnet_cidr, 0) == cidrhost("${var.backend_private_ip}/${split("/", var.backend_subnet_cidr)[1]}", 0)
      ])
      error_message = "Each FortiADC private IP must be inside its corresponding subnet CIDR."
    }

    precondition {
      condition = alltrue([
        !contains([for offset in [0, 1, -1] : cidrhost(var.frontend_subnet_cidr, offset)], var.frontend_private_ip),
        !contains([for offset in [0, 1, -1] : cidrhost(var.backend_subnet_cidr, offset)], var.backend_private_ip)
      ])
      error_message = "FortiADC private IPs cannot use OCI-reserved subnet addresses."
    }

    precondition {
      condition = local.use_existing_network || alltrue([
        tonumber(split("/", var.frontend_subnet_cidr)[1]) >= tonumber(split("/", var.vcn_cidr)[1]),
        tonumber(split("/", var.backend_subnet_cidr)[1]) >= tonumber(split("/", var.vcn_cidr)[1]),
        cidrhost(var.vcn_cidr, 0) == cidrhost("${cidrhost(var.frontend_subnet_cidr, 0)}/${split("/", var.vcn_cidr)[1]}", 0),
        cidrhost(var.vcn_cidr, 0) == cidrhost("${cidrhost(var.backend_subnet_cidr, 0)}/${split("/", var.vcn_cidr)[1]}", 0),
        cidrhost(var.frontend_subnet_cidr, 0) != cidrhost("${cidrhost(var.backend_subnet_cidr, 0)}/${split("/", var.frontend_subnet_cidr)[1]}", 0),
        cidrhost(var.backend_subnet_cidr, 0) != cidrhost("${cidrhost(var.frontend_subnet_cidr, 0)}/${split("/", var.backend_subnet_cidr)[1]}", 0)
      ])
      error_message = "For a new VCN or a reused VCN with new subnets, both subnets must be inside the selected VCN and must not overlap."
    }
  }
}
