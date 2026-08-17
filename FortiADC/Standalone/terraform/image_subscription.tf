resource "oci_core_app_catalog_listing_resource_version_agreement" "fortiadc" {
  count = local.matched_package != null ? 1 : 0

  listing_id               = local.matched_package.listing_id
  listing_resource_version = local.matched_package.version
}

resource "oci_core_app_catalog_subscription" "fortiadc" {
  count = local.matched_package != null && var.mp_subscription_enabled ? 1 : 0

  compartment_id           = var.compartment_ocid
  listing_id               = local.matched_package.listing_id
  listing_resource_version = local.matched_package.version
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.fortiadc[0].eula_link
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.fortiadc[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.fortiadc[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.fortiadc[0].time_retrieved

  timeouts {
    create = "30m"
  }
}
