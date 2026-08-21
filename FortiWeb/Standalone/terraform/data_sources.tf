data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_subnet" "management_existing" {
  count     = local.use_existing_network ? 1 : 0
  subnet_id = var.management_subnet_id
}

data "oci_core_subnet" "trust_existing" {
  count     = local.use_existing_network ? 1 : 0
  subnet_id = var.trust_subnet_id
}

data "oci_core_app_catalog_listing_resource_version" "fortiweb" {
  count = local.matched_package != null ? 1 : 0

  listing_id       = local.matched_package.listing_id
  resource_version = local.matched_package.resource_version
}
