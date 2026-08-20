resource "terraform_data" "validate_marketplace_package" {
  lifecycle {
    precondition {
      condition     = local.matched_package != null
      error_message = "Expected exactly one matching FortiWeb Marketplace package for the selected license/version. Check license_type, fortiweb_version, and final_listings.json."
    }
  }
}

resource "terraform_data" "validate_network" {
  lifecycle {
    precondition {
      condition = (
        local.create_new_vcn ||
        (
          local.use_existing_vcn &&
          trimspace(var.vcn_id) != "" &&
          length(data.oci_core_internet_gateways.existing[0].gateways) == 1 &&
          (
            (!local.use_existing_network && trimspace(var.management_subnet_cidr_block) != "" && trimspace(var.trust_subnet_cidr_block) != "") ||
            (local.use_existing_network && trimspace(var.management_subnet_id) != "" && trimspace(var.trust_subnet_id) != "")
          )
        )
      )
      error_message = "Set a valid network strategy: create a new VCN/subnets, reuse a VCN with new subnets, or reuse both an existing VCN and existing subnets."
    }
  }
}
