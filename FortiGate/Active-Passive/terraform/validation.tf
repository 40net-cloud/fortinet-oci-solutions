resource "terraform_data" "validate_marketplace_package" {
  lifecycle {
    precondition {
      condition = (
        local.license_type != null &&
        contains(["X64", "ARM64"], local.normalized_cpu_type) &&
        length(local.matched_packages) == 1
      )

      error_message = format(
        "Expected exactly one FortiGate Marketplace package, but found %d. Check LICENSE_TYPE, CPU_TYPE, FORTIOS_VERSION, and final_listings.json.",
        length(local.matched_packages)
      )
    }
  }
}