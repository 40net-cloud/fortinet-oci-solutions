locals {
  use_existing_network = (
    var.network_strategy ==
    var.network_strategy_enum["USE_EXISTING_VCN_SUBNET"]
  )

  mp_subscription_enabled = var.mp_subscription_enabled ? 1 : 0

  listings = jsondecode(
    file("${path.module}/final_listings.json")
  )

  fortigate_packages = flatten([
    for listing in local.listings : [
      for pkg in lookup(listing, "packages", []) : {
        license_type = try(
          pkg.package_info._pricing._type,
          null
        )

        cpu_type = can(
          regex(
            ".*arm.*",
            lower(pkg.package_info._app_catalog_listing_resource_version)
          )
        ) ? "ARM64" : "X64"

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

        ocpu_count = can(
          regex("\\((\\d+)\\s+cores\\)", listing.name)
          ) ? tonumber(
          regex("\\((\\d+)\\s+cores\\)", listing.name)[0]
        ) : null
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
        local.license_type != "PAYGO" ||
        pkg.ocpu_count == local.paygo_ocpu
      )
    ]),
    null
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
  var.cpu_type == "ARM64" && var.vm_compute_shape_arm != "" ?
  var.vm_compute_shape_arm :
  var.cpu_type == "X64" && var.vm_compute_shape_x64 != "" ?
  var.vm_compute_shape_x64 :
  null
)
}

locals {
  license_type = (
    can(regex("^PAYGO\\s\\d+\\sOCPUs$", var.license_type))
    ? "PAYGO"
    : "BYOL"
  )

  paygo_ocpu = (
    can(regex("^PAYGO\\s(\\d+)\\sOCPUs$", var.license_type))
    ? tonumber(
      regex(
        "^PAYGO\\s(\\d+)\\sOCPUs$",
        var.license_type
      )[0]
    )
    : null
  )
}