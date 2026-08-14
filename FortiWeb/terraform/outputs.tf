output "default_username" {
  description = "Default FortiWeb administrator username."
  value       = "admin"
}

output "fortiweb_a_instance_id" {
  description = "FortiWeb-A instance OCID. The initial password is the instance OCID."
  value       = try(oci_core_instance.fwba[0].id, null)
}

output "fortiweb_b_instance_id" {
  description = "FortiWeb-B instance OCID. The initial password is the instance OCID."
  value       = try(oci_core_instance.fwbb[0].id, null)
}

output "fortiweb_a_management_ip" {
  description = "Public management IP of FortiWeb-A, when public IP assignment is enabled."
  value       = try(oci_core_instance.fwba[0].public_ip, null)
}

output "fortiweb_b_management_ip" {
  description = "Public management IP of FortiWeb-B, when public IP assignment is enabled."
  value       = try(oci_core_instance.fwbb[0].public_ip, null)
}

output "fortiweb_a_management_url" {
  description = "FortiWeb-A HTTPS management URL."
  value = try(
    "https://${oci_core_instance.fwba[0].public_ip}:8443",
    null
  )
}

output "fortiweb_b_management_url" {
  description = "FortiWeb-B HTTPS management URL."
  value = try(
    "https://${oci_core_instance.fwbb[0].public_ip}:8443",
    null
  )
}

output "network_load_balancer_ip" {
  description = "Public IP address of the Network Load Balancer."
  value = try(
    oci_network_load_balancer_network_load_balancer.external[0].ip_addresses[0].ip_address,
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
