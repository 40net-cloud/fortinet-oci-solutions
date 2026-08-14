output "default_username" {
  description = "Default FortiWeb administrator username."
  value       = "admin"
}

output "fortiweb_instance_id" {
  description = "FortiWeb instance OCID. The initial password is the instance OCID."
  value       = try(oci_core_instance.fortiweb[0].id, null)
}

output "fortiweb_management_ip" {
  description = "Public management and application IP, when public IP assignment is enabled."
  value       = try(oci_core_instance.fortiweb[0].public_ip, null)
}

output "fortiweb_management_url" {
  description = "FortiWeb HTTPS management URL."
  value = try(
    "https://${oci_core_instance.fortiweb[0].public_ip}:8443",
    null
  )
}

output "selected_marketplace_image_id" {
  description = "Regional Marketplace image OCID resolved for the selected package."
  value = try(
    data.oci_core_app_catalog_listing_resource_version.fortiweb[0].listing_resource_id,
    null
  )
}

