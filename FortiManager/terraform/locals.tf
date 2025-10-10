locals {

  use_existing_network = var.network_strategy == var.network_strategy_enum["USE_EXISTING_VCN_SUBNET"] ? true : false
  
  # Marketplace subscription logic
  mp_subscription_enabled  = var.mp_subscription_enabled ? 1 : 0

  # is_flex_shape       = var.vm_compute_shape == "VM.Standard.E3.Flex" ? [var.vm_flex_shape_ocpus] : []

  # Load listings from external JSON
  listings = jsondecode(file("${path.module}/final_listings.json"))

  license_type = var.license_type

  # Flatten and parse FortiManager packages
  fortimanager_packages = flatten([
    for listing in local.listings : [
     for pkg in lookup(listing, "packages", []) : {
        license_type  = try(pkg.package_info._pricing._type, null),
        cpu_type      = can(regex(".*arm.*", lower(pkg.package_info._app_catalog_listing_resource_version))) ? "ARM64" : "X64"
        version       = regex("^([\\d.]+)", pkg.package_info._app_catalog_listing_resource_version)[0],
        image_id      = try(pkg.package_info._image_id, null),
        listing_id    = try(pkg.package_info._app_catalog_listing_id, null),
        resource_ver  = try(pkg.package_info._app_catalog_listing_resource_version, null)
        ocpu_count    = can(regex("\\((\\d+)\\s+cores\\)", listing.name)) ? tonumber(regex("\\((\\d+)\\s+cores\\)", listing.name)[0]) : null
       }
       if can(regex("fortimanager", lower(listing.name)))
    ]
  ])

    matched_package = try(
  one([
    for pkg in local.fortimanager_packages : pkg
    if pkg.license_type == local.license_type && pkg.version == var.fortios_version
  ]),
  null
)

    # Dynamically extracted values based on matched package
    mp_listing_id               = try(local.matched_package.listing_id, null)
    mp_listing_resource_id      = try(local.matched_package.image_id, null)
    mp_listing_resource_version = try(local.matched_package.resource_ver, null)

  vm_compute_shape = var.vm_compute_shape
}
