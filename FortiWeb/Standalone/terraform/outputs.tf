output "selected_fortiweb_package" {
  description = "Resolved FortiWeb marketplace package selected for deployment."
  value       = local.matched_package
}

output "selected_image_id" {
  description = "Regional FortiWeb Marketplace image ID selected for the deployment."
  value       = try(data.oci_core_app_catalog_listing_resource_version.fortiweb[0].listing_resource_id, null)
}

output "fortiweb_management_ip" {
  description = "Public management IP of the FortiWeb instance."
  value       = try(oci_core_instance.vm-a[0].public_ip, null)
}

output "fortiweb_admin_url" {
  description = "FortiWeb management URL."
  value       = try("https://${oci_core_instance.vm-a[0].public_ip}:8443", null)
}

output "fortiweb_default_username" {
  description = "Default FortiWeb admin username."
  value       = "admin"
}

output "management_subnet_gateway" {
  description = "First usable IP address of the selected management subnet."
  value       = local.management_subnet_gateway
}

output "trust_subnet_gateway" {
  description = "First usable IP address of the selected trust subnet."
  value       = local.trust_subnet_gateway
}

output "management_route_table_id" {
  description = "Route table associated with the management subnet."
  value       = local.management_route_table_id
}

output "trust_route_table_id" {
  description = "Route table associated with the trust subnet."
  value       = local.trust_route_table_id
}
