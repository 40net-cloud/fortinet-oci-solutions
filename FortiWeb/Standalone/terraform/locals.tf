locals {
  use_existing_vcn = var.network_strategy == "Use Existing VCN and Create New Subnets"

  listings = jsondecode(file("${path.module}/final_listings.json"))

  normalized_license_type     = upper(trimspace(var.license_type))
  normalized_fortiweb_version = trimspace(var.fortiweb_version)
  normalized_cpu_type         = upper(trimspace(var.cpu_type))

  fortiweb_packages = flatten([
    for listing in local.listings : [
      for package in lookup(listing, "packages", []) : {
        listing_name = lower(trimspace(listing.name))
        license_type = upper(try(package.package_info._pricing._type, ""))
        version = try(
          package.package_info._app_catalog_listing_resource_version,
          ""
        )
        image_id = try(
          package.package_info._image_id,
          null
        )
        listing_id = try(
          package.package_info._app_catalog_listing_id,
          null
        )
        resource_version = try(
          package.package_info._app_catalog_listing_resource_version,
          null
        )
      }
      if lower(trimspace(listing.name)) == "fortinet fortiweb web application and api protection platform"
    ]
  ])

  matched_packages = [
    for package in local.fortiweb_packages : package
    if package.license_type == local.normalized_license_type &&
    package.version == local.normalized_fortiweb_version
  ]

  matched_package = length(local.matched_packages) == 1 ? one(local.matched_packages) : null

  vm_compute_shape = var.vm_compute_shape_x64

  flex_shapes = toset([
    "VM.Standard3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.E5.Flex",
    "VM.Standard.E6.Flex"
  ])
}

