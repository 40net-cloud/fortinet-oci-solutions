variable "tenancy_ocid" {
  description = "OCI tenancy OCID. Resource Manager populates this automatically."
  type        = string
}

variable "compartment_ocid" {
  description = "Compartment in which the FortiWeb compute, storage, and Marketplace subscription resources are created."
  type        = string
}

variable "network_compartment_ocid" {
  description = "Compartment containing the existing VCN or in which the new VCN is created."
  type        = string
}

variable "region" {
  description = "OCI region in which to deploy the stack."
  type        = string
}

variable "prefix" {
  description = "Name of the FortiWeb instance and prefix used in resource display names."
  type        = string
  default     = "FortiWeb"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{0,19}$", var.prefix))
    error_message = "prefix must start with a letter and contain at most 20 letters, numbers, or hyphens."
  }
}

variable "availability_domain_name" {
  description = "Availability domain for the FortiWeb instance."
  type        = string
}

variable "fault_domain_name" {
  description = "Fault domain for the FortiWeb instance."
  type        = string
}

variable "license_type" {
  description = "FortiWeb Marketplace license type."
  type        = string
  default     = "BYOL"

  validation {
    condition     = contains(["BYOL"], upper(trimspace(var.license_type)))
    error_message = "The current FortiWeb Marketplace inventory supports BYOL only."
  }
}

variable "fortiweb_version" {
  description = "FortiWeb Marketplace image version."
  type        = string
  default     = "8.0.3"
}

variable "cpu_type" {
  description = "CPU architecture of the selected FortiWeb image and shape."
  type        = string
  default     = "X64"

  validation {
    condition     = upper(trimspace(var.cpu_type)) == "X64"
    error_message = "The current FortiWeb Marketplace inventory supports X64 only."
  }
}

variable "vm_compute_shape_x64" {
  description = "OCI X64 compute shape for the FortiWeb instance."
  type        = string
  default     = "VM.Standard.E5.Flex"

  validation {
    condition = contains([
      "VM.Standard2.2",
      "VM.Standard2.4",
      "VM.Standard2.8",
      "VM.Standard3.Flex",
      "VM.Standard.E4.Flex",
      "VM.Standard.E5.Flex",
      "VM.Standard.E6.Flex"
    ], var.vm_compute_shape_x64)
    error_message = "Select one of the supported X64 FortiWeb shapes."
  }
}

variable "ocpu_count" {
  description = "Number of OCPUs assigned to a Flex-shape FortiWeb instance."
  type        = number
  default     = 4

  validation {
    condition     = var.ocpu_count >= 2 && var.ocpu_count <= 64 && floor(var.ocpu_count) == var.ocpu_count
    error_message = "ocpu_count must be a whole number from 2 through 64."
  }
}

variable "memory_in_gbs" {
  description = "Memory assigned to a Flex-shape FortiWeb instance."
  type        = number
  default     = 16

  validation {
    condition     = var.memory_in_gbs >= 8 && var.memory_in_gbs <= 1024 && floor(var.memory_in_gbs) == var.memory_in_gbs
    error_message = "memory_in_gbs must be a whole number from 8 through 1024."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size for the FortiWeb instance."
  type        = number
  default     = 50

  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 32768
    error_message = "boot_volume_size_in_gbs must be between 50 and 32768 GB."
  }
}

variable "data_volume_size_in_gbs" {
  description = "Additional data volume size for the FortiWeb instance."
  type        = number
  default     = 50

  validation {
    condition     = var.data_volume_size_in_gbs >= 50 && var.data_volume_size_in_gbs <= 32768
    error_message = "data_volume_size_in_gbs must be between 50 and 32768 GB."
  }
}

variable "mp_subscription_enabled" {
  description = "Accept the Marketplace agreement and create the image subscription."
  type        = bool
  default     = true
}

variable "network_strategy" {
  description = "Create a VCN or create the FortiWeb subnets in an existing VCN."
  type        = string
  default     = "Create New VCN"

  validation {
    condition = contains([
      "Create New VCN",
      "Use Existing VCN and Create New Subnets"
    ], var.network_strategy)
    error_message = "network_strategy must be Create New VCN or Use Existing VCN and Create New Subnets."
  }
}

variable "vcn_id" {
  description = "Existing VCN OCID when the existing-VCN strategy is selected."
  type        = string
  default     = ""
}

variable "existing_igw_ocid" {
  description = "Internet Gateway OCID attached to the selected existing VCN."
  type        = string
  default     = ""
}

variable "vcn_cidr_block" {
  description = "CIDR block used when a new VCN is created."
  type        = string
  default     = "172.16.140.0/22"

  validation {
    condition     = can(cidrnetmask(var.vcn_cidr_block))
    error_message = "vcn_cidr_block must be a valid IPv4 CIDR."
  }
}

variable "untrust_subnet_cidr" {
  description = "CIDR for the FortiWeb port1 subnet."
  type        = string
  default     = "172.16.140.16/28"

  validation {
    condition     = can(cidrnetmask(var.untrust_subnet_cidr))
    error_message = "untrust_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "trust_subnet_cidr" {
  description = "CIDR for the FortiWeb port2 subnet."
  type        = string
  default     = "172.16.140.32/28"

  validation {
    condition     = can(cidrnetmask(var.trust_subnet_cidr))
    error_message = "trust_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "fwb_untrust_ip" {
  description = "Private IP for FortiWeb port1 in the untrusted subnet."
  type        = string
  default     = "172.16.140.20"
}

variable "fwb_trust_ip" {
  description = "Private IP for FortiWeb port2 in the trusted subnet."
  type        = string
  default     = "172.16.140.40"
}

variable "application_ingress_cidr" {
  description = "Client CIDR allowed to send application traffic directly to FortiWeb port1."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.application_ingress_cidr))
    error_message = "application_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "admin_ingress_cidr" {
  description = "Administrator CIDR allowed to connect to FortiWeb SSH and HTTPS management. Restrict this in production."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.admin_ingress_cidr))
    error_message = "admin_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "assign_public_ip" {
  description = "Assign a public IP to FortiWeb port1 for direct application and administrative access."
  type        = bool
  default     = true
}

