output "debug_marketplace_inputs" {
  description = "Inputs used to select the FortiGate Marketplace package."

  value = {
    cpu_type           = var.cpu_type
    fortios_version    = var.fortios_version
    license_type_input = var.license_type
    normalized_license = local.license_type
    paygo_ocpu         = local.paygo_ocpu
    vm_compute_shape   = local.vm_compute_shape
  }
}

output "debug_matching_packages" {
  description = "FortiGate Marketplace packages matching the requested inputs."

  value = [
    for pkg in local.fortigate_packages : {
      license_type = pkg.license_type
      cpu_type     = pkg.cpu_type
      version      = pkg.version
      listing_id   = pkg.listing_id
      resource_ver = pkg.resource_ver
      ocpu_count   = pkg.ocpu_count
    }
    if pkg.license_type == local.license_type &&
    pkg.cpu_type == var.cpu_type &&
    pkg.version == var.fortios_version &&
    (
      local.license_type != "PAYGO" ||
      pkg.ocpu_count == local.paygo_ocpu
    )
  ]
}

output "debug_matched_package_found" {
  description = "Whether exactly one Marketplace package was selected."
  value       = local.matched_package != null
}