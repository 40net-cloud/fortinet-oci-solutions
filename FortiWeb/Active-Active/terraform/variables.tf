variable "tenancy_ocid" {
  description = "OCI tenancy OCID. Resource Manager populates this automatically."
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID used for local API-key authentication."
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to the OCI API private key used for local API-key authentication."
  type        = string
  default     = ""
}

variable "fingerprint" {
  description = "OCI API key fingerprint used for local API-key authentication."
  type        = string
  default     = ""
}

variable "compartment_ocid" {
  description = "Compartment in which FortiWeb compute, storage, NLB, and Marketplace subscription resources are created."
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
  description = "Prefix used in resource display names."
  type        = string
  default     = "FortiWeb"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9-]{0,19}$", var.prefix))
    error_message = "prefix must start with a letter and contain at most 20 letters, numbers, or hyphens."
  }
}

variable "availability_domain_name_a" {
  description = "Availability domain for FortiWeb-A."
  type        = string
}

variable "fault_domain_name_a" {
  description = "Fault domain for FortiWeb-A."
  type        = string
}

variable "availability_domain_name_b" {
  description = "Availability domain for FortiWeb-B."
  type        = string
}

variable "fault_domain_name_b" {
  description = "Fault domain for FortiWeb-B."
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
  description = "OCI X64 compute shape for both FortiWeb instances."
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
  description = "Number of OCPUs assigned to each Flex-shape FortiWeb instance."
  type        = number
  default     = 4

  validation {
    condition     = var.ocpu_count >= 2 && var.ocpu_count <= 64 && floor(var.ocpu_count) == var.ocpu_count
    error_message = "ocpu_count must be a whole number from 2 through 64."
  }
}

variable "memory_in_gbs" {
  description = "Memory assigned to each Flex-shape FortiWeb instance."
  type        = number
  default     = 16

  validation {
    condition     = var.memory_in_gbs >= 8 && var.memory_in_gbs <= 1024 && floor(var.memory_in_gbs) == var.memory_in_gbs
    error_message = "memory_in_gbs must be a whole number from 8 through 1024."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size for each FortiWeb instance."
  type        = number
  default     = 50

  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 32768
    error_message = "boot_volume_size_in_gbs must be between 50 and 32768 GB."
  }
}

variable "data_volume_size_in_gbs" {
  description = "Additional data volume size for each FortiWeb instance."
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
  description = "Create a new VCN and subnets or use existing VCN and subnets."
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
  description = "Existing VCN OCID when the existing-VCN strategy is selected."
  type        = string
  default     = ""
}

variable "vcn_display_name" {
  description = "Display name for the new VCN created when the new-network strategy is selected."
  type        = string
  default     = "FortiWeb-Active-Active-VCN"
}

variable "vcn_dns_label" {
  description = "DNS label for the new VCN created when the new-network strategy is selected."
  type        = string
  default     = "fwbvcn"
}

variable "lb_subnet_id" {
  description = "Existing public NLB subnet OCID when using an existing network."
  type        = string
  default     = ""
}

variable "lb_subnet_display_name" {
  description = "Display name for the new NLB subnet created when the new-network strategy is selected."
  type        = string
  default     = "FortiWeb-Active-Active-LB-Subnet"
}

variable "lb_subnet_dns_label" {
  description = "DNS label for the new NLB subnet created when the new-network strategy is selected."
  type        = string
  default     = "fwblb"
}

variable "untrust_subnet_id" {
  description = "Existing FortiWeb port1 subnet OCID when using an existing network."
  type        = string
  default     = ""
}

variable "untrust_subnet_display_name" {
  description = "Display name for the new FortiWeb untrusted subnet created when the new-network strategy is selected."
  type        = string
  default     = "FortiWeb-Active-Active-Untrust-Subnet"
}

variable "untrust_subnet_dns_label" {
  description = "DNS label for the new FortiWeb untrusted subnet created when the new-network strategy is selected."
  type        = string
  default     = "fwbuntrust"
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

variable "lb_subnet_cidr" {
  description = "CIDR for the public Network Load Balancer subnet."
  type        = string
  default     = "172.16.140.0/28"

  validation {
    condition     = can(cidrnetmask(var.lb_subnet_cidr))
    error_message = "lb_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "untrust_subnet_cidr" {
  description = "CIDR for the FortiWeb untrusted interfaces."
  type        = string
  default     = "172.16.140.16/28"

  validation {
    condition     = can(cidrnetmask(var.untrust_subnet_cidr))
    error_message = "untrust_subnet_cidr must be a valid IPv4 CIDR."
  }
}

variable "fwba_untrust_ip" {
  description = "Optional private IP for FortiWeb-A port1 in the untrusted subnet. Leave empty to let OCI assign one automatically."
  type        = string
  default     = ""
}

variable "fwbb_untrust_ip" {
  description = "Optional private IP for FortiWeb-B port1 in the untrusted subnet. Leave empty to let OCI assign one automatically."
  type        = string
  default     = ""
}

variable "application_ingress_cidr" {
  description = "Client CIDR allowed to send application traffic through the public NLB."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.application_ingress_cidr))
    error_message = "application_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "admin_ingress_cidr" {
  description = "Administrator CIDR allowed to connect directly to FortiWeb SSH and HTTPS management. Restrict this in production."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrnetmask(var.admin_ingress_cidr))
    error_message = "admin_ingress_cidr must be a valid IPv4 CIDR."
  }
}

variable "assign_public_ip" {
  description = "Assign public IPs to the FortiWeb untrusted interfaces for direct administration."
  type        = bool
  default     = true
}

variable "health_check_port" {
  description = "TCP port used by the NLB health checker."
  type        = number
  default     = 8443

  validation {
    condition     = var.health_check_port >= 1 && var.health_check_port <= 65535
    error_message = "health_check_port must be from 1 through 65535."
  }
}
