output "selected_fortigate_package" {
  value = local.matched_package
}

output "selected_image_id" {
  value = try(local.matched_package.image_id, null)
}

output "selected_configuration" {
  value = {
    license_input = var.license_type
    license_type  = local.license_type
    paygo_ocpus   = local.paygo_ocpu
    fortios       = var.fortios_version
    cpu           = var.cpu_type
    shape         = local.vm_compute_shape
    ocpus         = var.ocpu_count
    memory        = var.memory_in_gbs
  }
}