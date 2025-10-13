locals {

  use_existing_network = var.network_strategy == var.network_strategy_enum["USE_EXISTING_VCN_SUBNET"] ? true : false

  # Marketplace subscription logic
  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0

  # is_flex_shape       = var.vm_compute_shape == "VM.Standard.E3.Flex" ? [var.vm_flex_shape_ocpus] : []

  # Load listings from external JSON
  listings = jsondecode(file("${path.module}/final_listings.json"))

  # Flatten and parse FortiGate packages
  fortigate_packages = flatten([
    for listing in local.listings : [
      for pkg in lookup(listing, "packages", []) : {
        license_type = try(pkg.package_info._pricing._type, null),
        cpu_type     = can(regex(".*arm.*", lower(pkg.package_info._app_catalog_listing_resource_version))) ? "ARM64" : "X64"
        version      = regex("^([\\d.]+)", pkg.package_info._app_catalog_listing_resource_version)[0],
        image_id     = try(pkg.package_info._image_id, null),
        listing_id   = try(pkg.package_info._app_catalog_listing_id, null),
        resource_ver = try(pkg.package_info._app_catalog_listing_resource_version, null)
        ocpu_count   = can(regex("\\((\\d+)\\s+cores\\)", listing.name)) ? tonumber(regex("\\((\\d+)\\s+cores\\)", listing.name)[0]) : null
      }
      if can(regex("fortigate", lower(listing.name)))
    ]
  ])

  matched_package = try(
    one([
      for pkg in local.fortigate_packages : pkg
      if pkg.license_type == local.license_type &&
      pkg.cpu_type == var.cpu_type &&
      pkg.version == var.fortios_version &&
      (
        local.license_type != "PAYGO" || pkg.ocpu_count == local.paygo_ocpu
      )
    ]),
    null
  )

  # Dynamically extracted values based on matched package
  mp_listing_id               = try(local.matched_package.listing_id, null)
  mp_listing_resource_id      = try(local.matched_package.image_id, null)
  mp_listing_resource_version = try(local.matched_package.resource_ver, null)

  vm_compute_shape = (
    var.vm_compute_shape_arm != "" ? var.vm_compute_shape_arm :
    var.vm_compute_shape_x64 != "" ? var.vm_compute_shape_x64 :
    null
  )
}

locals {
  license_type = (
    can(regex("^PAYGO\\s\\d+\\sOCPUs$", var.license_type)) ? "PAYGO" : "BYOL"
  )

  paygo_ocpu = (
    can(regex("^PAYGO\\s(\\d+)\\sOCPUs$", var.license_type))
    ? tonumber(regex("^PAYGO\\s(\\d+)\\sOCPUs$", var.license_type)[0])
    : null
  )
}

# PAYGO image_id logic
locals {
  paygo_listings = [
    for listing in jsondecode(file("${path.module}/final_listings.json")) :
    listing if can(regex("fortigate next-gen firewall", lower(listing.name)))
    && can(regex("cores", lower(listing.name)))
    && !can(regex("special", lower(listing.name)))
  ]

  selected_paygo_listing = local.license_type == "PAYGO" && local.paygo_ocpu != null ? (
    length([
      for l in local.paygo_listings :
      l if lower(trimspace(l.name)) == lower(format("fortigate next-gen firewall (%d cores)", local.paygo_ocpu))
    ]) > 0 ?
    one([
      for l in local.paygo_listings :
      l if lower(trimspace(l.name)) == lower(format("fortigate next-gen firewall (%d cores)", local.paygo_ocpu))
    ]) :
    null
  ) : null

  selected_paygo_package = local.license_type == "PAYGO" && local.selected_paygo_listing != null ? (
    one([
      for package in local.selected_paygo_listing.packages :
      package if trimspace(package.package_version) == "${var.fortios_version} ( ${var.cpu_type} )"
    ])
  ) : null

  paygo_image_id = local.selected_paygo_package != null ? local.selected_paygo_package.package_info._image_id : null

}
