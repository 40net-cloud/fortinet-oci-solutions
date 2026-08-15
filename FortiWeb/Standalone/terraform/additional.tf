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
      condition     = !local.use_existing_network || (trimspace(var.vcn_id) != "" && trimspace(var.management_subnet_id) != "" && trimspace(var.trust_subnet_id) != "")
      error_message = "When using an existing VCN, set vcn_id, management_subnet_id, and trust_subnet_id."
    }
  }
}
