locals {
  use_existing_network = (
    var.network_strategy ==
    var.network_strategy_enum["USE_EXISTING_VCN_SUBNET"]
  )

  listings = jsondecode(
    file("${path.module}/final_listings.json")
  )

  normalized_license_type = upper(trimspace(var.license_type))
  normalized_cpu_type     = upper(trimspace(var.cpu_type))
  normalized_fortios      = trimspace(var.fortios_version)

  license_type = (
    local.normalized_license_type == "BYOL" ? "BYOL" :
    can(regex(
      "^PAYGO\\s+[0-9]+\\s+OCPUS$",
      local.normalized_license_type
    )) ? "PAYGO" :
    null
  )

  paygo_ocpu = local.license_type == "PAYGO" ? tonumber(
    regex(
      "^PAYGO\\s+([0-9]+)\\s+OCPUS$",
      local.normalized_license_type
    )[0]
  ) : null

  expected_listing_name = (
    local.license_type == "BYOL"
    ? "fortigate next-gen firewall (byol)"
    : (
      local.license_type == "PAYGO" && local.paygo_ocpu != null
      ? lower(format(
        "fortigate next-gen firewall (%d cores)",
        local.paygo_ocpu
      ))
      : null
    )
  )

  fortigate_packages = flatten([
    for listing in local.listings : [
      for pkg in lookup(listing, "packages", []) : {
        listing_name = lower(trimspace(listing.name))
        license_type = try(pkg.package_info._pricing._type, null)
        cpu_type = can(regex(
          "arm",
          lower(pkg.package_info._app_catalog_listing_resource_version)
        )) ? "ARM64" : "X64"
        version = regex(
          "^([\\d.]+)",
          pkg.package_info._app_catalog_listing_resource_version
        )[0]
        image_id = try(
          pkg.package_info._image_id,
          null
        )
        listing_id = try(
          pkg.package_info._app_catalog_listing_id,
          null
        )
        resource_ver = try(
          pkg.package_info._app_catalog_listing_resource_version,
          null
        )
      }
      if can(regex("fortigate", lower(listing.name)))
    ]
  ])

  matched_packages = [
    for pkg in local.fortigate_packages : pkg
    if pkg.license_type == local.license_type &&
    pkg.cpu_type == local.normalized_cpu_type &&
    pkg.version == local.normalized_fortios &&
    pkg.listing_name == local.expected_listing_name
  ]

  matched_package = (
    length(local.matched_packages) == 1
    ? one(local.matched_packages)
    : null
  )

  mp_listing_id = try(
    local.matched_package.listing_id,
    null
  )

  mp_listing_resource_id = try(
    local.matched_package.image_id,
    null
  )

  mp_listing_resource_version = try(
    local.matched_package.resource_ver,
    null
  )

  vm_compute_shape = (
    local.normalized_cpu_type == "ARM64" ? var.vm_compute_shape_arm :
    local.normalized_cpu_type == "X64" ? var.vm_compute_shape_x64 :
    null
  )
}