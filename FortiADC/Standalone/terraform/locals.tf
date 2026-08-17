locals {
  create_new_vcn       = var.network_strategy == "Create New VCN and Subnets"
  use_existing_vcn     = var.network_strategy == "Use Existing VCN and Create New Subnets" || var.network_strategy == "Use Existing VCN and Subnets"
  use_existing_network = var.network_strategy == "Use Existing VCN and Subnets"

  listings = jsondecode(file("${path.module}/final_listings.json"))

  fortiadc_packages = flatten([
    for listing in local.listings : [
      for package in lookup(listing, "packages", []) : {
        license_type = upper(try(package.license_type, ""))
        version      = try(package.resource_version, "")
        listing_id   = try(package.listing_id, null)
      }
      if lower(trimspace(listing.name)) == "fortinet fortiadc application delivery controller"
    ]
  ])

  matched_packages = [
    for package in local.fortiadc_packages : package
    if package.license_type == upper(trimspace(var.license_type)) &&
    package.version == trimspace(var.fortiadc_version)
  ]

  matched_package = length(local.matched_packages) == 1 ? one(local.matched_packages) : null

  selected_vcn_id          = local.use_existing_vcn ? var.vcn_id : oci_core_vcn.fortiadc[0].id
  selected_front_subnet_id = local.use_existing_network ? var.frontend_subnet_id : oci_core_subnet.frontend[0].id
  selected_back_subnet_id  = local.use_existing_network ? var.backend_subnet_id : oci_core_subnet.backend[0].id
}
