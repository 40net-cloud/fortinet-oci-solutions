data "oci_core_vcn" "existing" {
  count  = local.use_existing_vcn ? 1 : 0
  vcn_id = var.vcn_id
}

# Resolve the selected package to the image OCID in the deployment region.
# The image_id recorded in final_listings.json belongs to the region in which
# the inventory workflow ran and must not be used directly in every region.
data "oci_core_app_catalog_listing_resource_version" "fortiweb" {
  count = local.matched_package != null ? 1 : 0

  listing_id       = local.matched_package.listing_id
  resource_version = local.matched_package.resource_version
}
