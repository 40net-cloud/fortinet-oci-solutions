provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

terraform {
  required_version = ">=1.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">=5.17.0"
    }
    template = ">=2.2.0"
  }
}