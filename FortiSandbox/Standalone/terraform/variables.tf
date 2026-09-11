variable "tenancy_ocid" {
  description = "OCID of the OCI tenancy."
  type        = string
}

variable "region" {
  description = "OCI region in which to deploy FortiSandbox."
  type        = string
}

variable "compartment_ocid" {
  description = "OCID of the compartment for compute and networking resources."
  type        = string
}

variable "availability_domain_name" {
  description = "Availability domain for the FortiSandbox instance. Leave blank to auto-select the first AD."
  type        = string
  default     = ""
}

variable "fault_domain_name" {
  description = "Fault domain for the FortiSandbox instance."
  type        = string
  default     = null
  nullable    = true
}

variable "fortisandbox_version" {
  description = "FortiSandbox Marketplace package version."
  type        = string
  default     = "FortiSandbox_5.2.0_GA_BYOL"

  validation {
    condition = contains([
      "FortiSandbox_5.2.0_GA_BYOL",
      "FortiSandbox_5.0.6_GA_BYOL",
      "FortiSandbox_5.0.5_GA_BYOL",
      "FortiSandbox 5.0.2 GA BYOL"
    ], var.fortisandbox_version)
    error_message = "fortisandbox_version must be one of the FortiSandbox Marketplace package versions currently published in final_listings.json."
  }
}

variable "license_type" {
  description = "FortiSandbox licensing model. This deployment supports BYOL only."
  type        = string
  default     = "BYOL"

  validation {
    condition     = upper(trimspace(var.license_type)) == "BYOL"
    error_message = "Only the BYOL FortiSandbox Marketplace package is supported."
  }
}

variable "vm_display_name" {
  description = "Display name of the FortiSandbox instance."
  type        = string
  default     = "FortiSandbox-Standalone"
}

variable "vm_compute_shape" {
  description = "OCI x86 VM shape for FortiSandbox."
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
  description = "Create a new VCN and subnets or use an existing VCN and subnets."
  type        = string
  default     = "Create New VCN and Subnets"

  validation {
    condition = contains([
      "Create New VCN and Subnets",
      "Use Existing VCN and Subnets"
    ], var.network_strategy)
    error_message = "Choose either Create New VCN and Subnets or Use Existing VCN and Subnets."
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

variable "vcn_display_name" {
  description = "Name of the VCN created by the template."
  type        = string
  default     = "FortiSandbox-VCN"
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

variable "frontend_private_ip" {
  description = "Optional private IP assigned to port1. Leave blank for OCI automatic allocation."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.frontend_private_ip) == "" || (can(cidrhost("${trimspace(var.frontend_private_ip)}/32", 0)) && !can(regex("(^|\\.)0[0-9]", trimspace(var.frontend_private_ip))))
    error_message = "frontend_private_ip must be a valid IPv4 address without leading zeros in any octet."
  }
}

variable "assign_public_ip" {
  description = "Assign an ephemeral public IP to port1."
  type        = bool
  default     = true
}

variable "management_cidr" {
  description = "IPv4 CIDR allowed to reach FortiSandbox HTTPS and SSH management on port1. Restrict this in production."
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
