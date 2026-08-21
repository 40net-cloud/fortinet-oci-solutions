data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_subnet" "frontend_existing" {
  count     = local.use_existing_network ? 1 : 0
  subnet_id = var.frontend_subnet_id
}

data "oci_core_subnet" "backend_existing" {
  count     = local.use_existing_network ? 1 : 0
  subnet_id = var.backend_subnet_id
}

# Resolve the selected Marketplace package to the image OCID for the deployment
# region. Marketplace image OCIDs are regional and must not be hardcoded.
data "oci_core_app_catalog_listing_resource_version" "fortiadc" {
  count = local.matched_package != null ? 1 : 0

  listing_id       = local.matched_package.listing_id
  resource_version = local.matched_package.version
}
