variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy."
  type        = string
}

variable "region" {
  description = "OCI region in which to deploy FortiADC."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment for compute and networking resources."
  type        = string
}

variable "availability_domain_name" {
  description = "Availability domain for the FortiADC instance. Leave blank to auto-select the first AD."
  type        = string
  default     = ""
}

variable "fault_domain_name" {
  description = "Fault domain for the FortiADC instance."
  type        = string
  default     = null
  nullable    = true
}

variable "fortiadc_version" {
  description = "FortiADC Marketplace package version."
  type        = string
  default     = "6.1.1"

  validation {
    condition     = contains(["6.1.1", "6.0.1", "5.4"], var.fortiadc_version)
    error_message = "fortiadc_version must be 6.1.1, 6.0.1, or 5.4."
  }
}

variable "license_type" {
  description = "FortiADC licensing model. This deployment supports BYOL only."
  type        = string
  default     = "BYOL"

  validation {
    condition     = upper(trimspace(var.license_type)) == "BYOL"
    error_message = "Only the BYOL FortiADC Marketplace package is supported."
  }
}

variable "vm_display_name" {
  description = "Display name of the FortiADC instance."
  type        = string
  default     = "FortiADC-Standalone"
}

variable "vm_compute_shape" {
  description = "OCI x86 VM shape for FortiADC."
  type        = string
  default     = "VM.Standard2.2"
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB."
  type        = number
  default     = 50

  validation {
    condition     = var.boot_volume_size_in_gbs >= 50
    error_message = "boot_volume_size_in_gbs must be at least 50 GB."
  }
}

variable "mp_subscription_enabled" {
  description = "Accept the Marketplace terms and create the subscription. Disable only if already subscribed."
  type        = bool
  default     = true
}

variable "network_strategy" {
  description = "Create a new VCN, reuse an existing VCN with new subnets, or reuse both an existing VCN and subnets."
  type        = string
  default     = "Create New VCN and Subnets"

  validation {
    condition = contains([
      "Create New VCN and Subnets",
      "Use Existing VCN and Create New Subnets",
      "Use Existing VCN and Subnets"
    ], var.network_strategy)
    error_message = "Choose one of: Create New VCN and Subnets, Use Existing VCN and Create New Subnets, or Use Existing VCN and Subnets."
  }
}

variable "vcn_id" {
  description = "Existing VCN OCID. Required when using existing networking."
  type        = string
  default     = ""
}

variable "frontend_subnet_id" {
  description = "Existing port1/frontend subnet OCID. Required when using existing networking."
  type        = string
  default     = ""
}

variable "backend_subnet_id" {
  description = "Existing port2/backend subnet OCID. Required when using existing networking."
  type        = string
  default     = ""
}

variable "internet_gateway_id" {
  description = "Existing Internet Gateway OCID. Required when using an existing VCN."
  type        = string
  default     = ""
}

variable "vcn_display_name" {
  description = "Name of the VCN created by the template."
  type        = string
  default     = "FortiADC-VCN"
}

variable "vcn_cidr" {
  description = "CIDR of the VCN created by the template."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vcn_cidr, 0))
    error_message = "vcn_cidr must be a valid IPv4 CIDR."
  }
}

variable "frontend_subnet_cidr" {
  description = "CIDR of the public port1/frontend subnet. Also used to validate the static port1 IP."
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.frontend_subnet_cidr, 0))
    error_message = "frontend_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "backend_subnet_cidr" {
  description = "CIDR of the private port2/backend subnet. Also used to configure port2."
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition     = can(cidrhost(var.backend_subnet_cidr, 0))
    error_message = "backend_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "frontend_private_ip" {
  description = "Static private IP assigned to port1."
  type        = string
  default     = "10.0.1.10"
}

variable "backend_private_ip" {
  description = "Static private IP assigned to port2."
  type        = string
  default     = "10.0.2.10"
}

variable "assign_public_ip" {
  description = "Assign an ephemeral public IP to port1."
  type        = bool
  default     = true
}

variable "management_cidr" {
  description = "IPv4 CIDR allowed to reach FortiADC HTTPS and SSH management on port1. Restrict this in production."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.management_cidr, 0))
    error_message = "management_cidr must be a valid IPv4 CIDR."
  }
}

variable "client_ingress_cidr" {
  description = "IPv4 CIDR allowed to reach application virtual services on port1."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.client_ingress_cidr, 0))
    error_message = "client_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "client_port_min" {
  description = "First TCP port allowed for client traffic on port1."
  type        = number
  default     = 80

  validation {
    condition     = var.client_port_min >= 1 && var.client_port_min <= 65535
    error_message = "client_port_min must be between 1 and 65535."
  }
}

variable "client_port_max" {
  description = "Last TCP port allowed for client traffic on port1."
  type        = number
  default     = 443

  validation {
    condition     = var.client_port_max >= 1 && var.client_port_max <= 65535
    error_message = "client_port_max must be between 1 and 65535."
  }
}
