output "default_username" {
  description = "Default FortiADC administrator username."
  value       = "admin"
}

output "initial_password" {
  description = "FortiADC's initial password is the instance OCID. Change it immediately after login."
  value       = try(oci_core_instance.fortiadc[0].id, null)
  sensitive   = true
}

output "instance_id" {
  description = "FortiADC instance OCID."
  value       = try(oci_core_instance.fortiadc[0].id, null)
}

output "management_public_ip" {
  description = "Ephemeral public IP assigned to port1, when enabled."
  value       = try(oci_core_instance.fortiadc[0].public_ip, null)
}

output "management_url" {
  description = "FortiADC HTTPS management URL, when a port1 public IP is assigned."
  value       = try("https://${oci_core_instance.fortiadc[0].public_ip}", null)
}

output "frontend_private_ip" {
  description = "Private IP assigned to port1."
  value       = try(oci_core_instance.fortiadc[0].private_ip, null)
}

output "backend_private_ip" {
  description = "Private IP assigned to port2."
  value       = var.backend_private_ip
}

output "selected_marketplace_image_id" {
  description = "Regional Marketplace image OCID selected for FortiADC."
  value       = try(data.oci_core_app_catalog_listing_resource_version.fortiadc[0].listing_resource_id, null)
}
