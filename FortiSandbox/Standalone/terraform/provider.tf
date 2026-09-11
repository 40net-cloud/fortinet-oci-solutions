terraform {
  required_version = ">= 1.4.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.17.0"
    }
  }
}

# OCI Resource Manager supplies authentication automatically. Local runs use
# the standard OCI CLI configuration or OCI provider environment variables.
provider "oci" {
  region = var.region
}
