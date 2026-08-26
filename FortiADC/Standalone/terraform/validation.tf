resource "terraform_data" "validate_network" {
  lifecycle {
    precondition {
      condition     = local.use_existing_network || trimspace(var.backend_private_ip) != ""
      error_message = "backend_private_ip is required when creating a new VCN and subnets; leave it blank only when using existing subnets."
    }
  }
}