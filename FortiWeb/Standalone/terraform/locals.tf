locals {
  create_new_vcn       = var.network_strategy == "Create New VCN and Subnets"
  use_existing_vcn     = var.network_strategy == "Use Existing VCN and Create New Subnets" || var.network_strategy == "Use Existing VCN and Subnets"
  use_existing_network = var.network_strategy == "Use Existing VCN and Subnets"

  management_subnet_cidr    = local.use_existing_network ? data.oci_core_subnet.management_existing[0].cidr_block : var.management_subnet_cidr_block
  trust_subnet_cidr         = local.use_existing_network ? data.oci_core_subnet.trust_existing[0].cidr_block : var.trust_subnet_cidr_block
  management_subnet_gateway = cidrhost(local.management_subnet_cidr, 1)
  trust_subnet_gateway      = cidrhost(local.trust_subnet_cidr, 1)
  existing_igw_ocid         = local.use_existing_vcn && length(data.oci_core_internet_gateways.existing[0].gateways) == 1 ? data.oci_core_internet_gateways.existing[0].gateways[0].id : null

  listings = jsondecode(file("${path.module}/final_listings.json"))

  normalized_license_type     = upper(trimspace(var.license_type))
  normalized_fortiweb_version = trimspace(var.fortiweb_version)

  fortiweb_packages = flatten([
    for listing in local.listings : [
      for package in lookup(listing, "packages", []) : {
        listing_name     = lower(trimspace(listing.name))
        license_type     = upper(try(package.package_info._pricing._type, ""))
        version          = try(package.package_info._app_catalog_listing_resource_version, "")
        image_id         = try(package.package_info._image_id, null)
        listing_id       = try(package.package_info._app_catalog_listing_id, null)
        resource_version = try(package.package_info._app_catalog_listing_resource_version, null)
      }
      if lower(trimspace(listing.name)) == "fortinet fortiweb web application and api protection platform"
    ]
  ])

  matched_package = try(
    one([
      for pkg in local.fortiweb_packages : pkg
      if pkg.license_type == local.normalized_license_type && pkg.version == local.normalized_fortiweb_version
    ]),
    null
  )

  vm_compute_shape = var.vm_compute_shape_x64
}
