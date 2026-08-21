locals {
  create_new_vcn       = var.network_strategy == "Create New VCN and Subnets"
  use_existing_vcn     = var.network_strategy == "Use Existing VCN and Subnets"
  use_existing_network = var.network_strategy == "Use Existing VCN and Subnets"

  listings = jsondecode(file("${path.module}/final_listings.json"))

  normalized_license_type     = upper(trimspace(var.license_type))
  normalized_fortiadc_version = trimspace(var.fortiadc_version)

  fortiadc_packages = flatten([
    for listing in local.listings : [
      for package in lookup(listing, "packages", []) : {
        listing_name     = lower(trimspace(listing.name))
        license_type     = upper(try(package.package_info._pricing._type, ""))
        version          = try(package.package_info._app_catalog_listing_resource_version, "")
        image_id         = try(package.package_info._image_id, null)
        listing_id       = try(package.package_info._app_catalog_listing_id, null)
        resource_version = try(package.package_info._app_catalog_listing_resource_version, null)
      }
      if lower(trimspace(listing.name)) == "fortinet fortiadc application delivery controller"
    ]
  ])

  matched_package = try(
    one([
      for pkg in local.fortiadc_packages : pkg
      if pkg.license_type == local.normalized_license_type && pkg.version == local.normalized_fortiadc_version
    ]),
    null
  )

  selected_vcn_id          = local.use_existing_vcn ? var.vcn_id : oci_core_vcn.fortiadc[0].id
  selected_front_subnet_id = local.use_existing_network ? var.frontend_subnet_id : oci_core_subnet.frontend[0].id
  selected_back_subnet_id  = local.use_existing_network ? var.backend_subnet_id : oci_core_subnet.backend[0].id
  selected_frontend_cidr   = local.use_existing_network ? data.oci_core_subnet.frontend_existing[0].cidr_block : var.frontend_subnet_cidr
  selected_backend_cidr    = local.use_existing_network ? data.oci_core_subnet.backend_existing[0].cidr_block : var.backend_subnet_cidr
}
