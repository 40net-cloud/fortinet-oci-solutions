terraform {
  required_version = ">= 1.4.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.17.0"
    }
  }
}

# OCI Resource Manager supplies authentication through its resource principal.
# For local Terraform runs, the OCI provider uses the normal local OCI CLI
# configuration unless other provider authentication variables are supplied.
provider "oci" {
  region = var.region
}
