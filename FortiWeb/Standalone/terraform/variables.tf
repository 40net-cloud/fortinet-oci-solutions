############################
# Hidden Variable Group
############################
variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string
}

variable "user_ocid" {
  description = "OCI user OCID"
  type        = string
  default     = ""
}

variable "private_key_path" {
  description = "Path to OCI API private key"
  type        = string
  default     = ""
}

variable "fingerprint" {
  description = "OCI API key fingerprint"
  type        = string
  default     = ""
}

variable "region" {
  description = "OCI region"
  type        = string
}

############################
# Marketplace image
############################
variable "mp_subscription_enabled" {
  description = "Subscribe to the FortiWeb marketplace listing"
  type        = bool
  default     = true
}

############################
# Compute configuration
############################
variable "vm_display_name" {
  description = "FortiWeb instance display name"
  type        = string
  default     = "FortiWeb-Standalone"
}

variable "compartment_ocid" {
  description = "Compartment for compute, network, and marketplace subscription resources"
  type        = string
}

variable "availability_domain_name_1" {
  description = "Availability Domain for FortiWeb instance"
  type        = string
  default     = ""
}

variable "fault_domain_name_1" {
  description = "Fault Domain for FortiWeb instance"
  type        = string
  default     = ""
}

variable "license_type" {
  description = "Marketplace license type"
  type        = string
  default     = "BYOL"
}

variable "fortiweb_version" {
  description = "FortiWeb marketplace version"
  type        = string
  default     = "8.0.3"
}

variable "cpu_type" {
  description = "CPU type for selected image"
  type        = string
  default     = "X64"

  validation {
    condition     = upper(trimspace(var.cpu_type)) == "X64"
    error_message = "The current FortiWeb Marketplace inventory supports X64 only."
  }
}

variable "vm_compute_shape_x64" {
  description = "OCI X64 compute shape"
  type        = string
  default     = "VM.Standard.E5.Flex"
}

variable "ocpu_count" {
  description = "OCPUs for Flex-shape instances"
  type        = number
  default     = 4
}

variable "memory_in_gbs" {
  description = "Memory in GB for Flex-shape instances"
  type        = number
  default     = 16
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB"
  type        = number
  default     = 50
}

variable "data_volume_size_in_gbs" {
  description = "Data volume size in GB"
  type        = number
  default     = 50
}

variable "instance_launch_options_network_type" {
  description = "Instance NIC attachment type"
  type        = string
  default     = "PARAVIRTUALIZED"
}

############################
# Network configuration
############################
variable "network_strategy" {
  description = "Create a VCN, reuse a VCN with new subnets, or reuse both the VCN and subnets"
  type        = string
  default     = "Create New VCN and Subnets"

  validation {
    condition = contains([
      "Create New VCN and Subnets",
      "Use Existing VCN and Create New Subnets",
      "Use Existing VCN and Subnets"
    ], var.network_strategy)
    error_message = "network_strategy must be one of: Create New VCN and Subnets, Use Existing VCN and Create New Subnets, Use Existing VCN and Subnets."
  }
}

variable "vcn_id" {
  description = "Existing VCN OCID"
  type        = string
  default     = ""
}

variable "existing_igw_ocid" {
  description = "Existing Internet Gateway OCID for an existing VCN"
  type        = string
  default     = ""
}

variable "vcn_display_name" {
  description = "VCN display name"
  type        = string
  default     = "FortiWeb-Hub-VCN"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS label"
  type        = string
  default     = "fwbvcn"
}

variable "management_subnet_id" {
  description = "Management/public subnet OCID when reusing an existing VCN"
  type        = string
  default     = ""
}

variable "management_subnet_display_name" {
  description = "Management subnet display name"
  type        = string
  default     = "management-subnet"
}

variable "management_subnet_cidr_block" {
  description = "Management subnet CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "management_subnet_dns_label" {
  description = "Management subnet DNS label"
  type        = string
  default     = "mgmt"
}

variable "trust_subnet_id" {
  description = "Trust subnet OCID when reusing an existing VCN"
  type        = string
  default     = ""
}

variable "trust_subnet_display_name" {
  description = "Trust subnet display name"
  type        = string
  default     = "trust-subnet"
}

variable "trust_subnet_cidr_block" {
  description = "Trust subnet CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "trust_subnet_dns_label" {
  description = "Trust subnet DNS label"
  type        = string
  default     = "trust"
}

variable "management_routetable_display_name" {
  description = "Management route table display name"
  type        = string
  default     = "Management-Route-Table"
}

variable "trust_routetable_display_name" {
  description = "Trust route table display name"
  type        = string
  default     = "Trust-Route-Table"
}

variable "management_routetable_display_name_existing" {
  description = "Management route table name for existing network"
  type        = string
  default     = "Management-Route-Table-Existing"
}

variable "trust_routetable_display_name_existing" {
  description = "Trust route table name for existing network"
  type        = string
  default     = "Trust-Route-Table-Existing"
}

############################
# IP addresses and gateways
############################
variable "mgmt_private_ip" {
  description = "Optional private IP for FortiWeb management/public interface; leave blank for OCI automatic allocation"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.mgmt_private_ip) == "" || (can(cidrhost("${trimspace(var.mgmt_private_ip)}/32", 0)) && !can(regex("(^|\\.)0[0-9]", trimspace(var.mgmt_private_ip))))
    error_message = "mgmt_private_ip must be a valid IPv4 address without leading zeros in any octet, for example 10.1.0.10."
  }
}

variable "trust_private_ip" {
  description = "Optional private IP for FortiWeb trust interface; leave blank for OCI automatic allocation"
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.trust_private_ip) == "" || (can(cidrhost("${trimspace(var.trust_private_ip)}/32", 0)) && !can(regex("(^|\\.)0[0-9]", trimspace(var.trust_private_ip))))
    error_message = "trust_private_ip must be a valid IPv4 address without leading zeros in any octet, for example 10.0.2.10."
  }
}

variable "mgmt_subnet_gateway" {
  description = "Management subnet gateway"
  type        = string
  default     = "10.0.1.1"
}

variable "trust_subnet_gateway" {
  description = "Trust subnet gateway"
  type        = string
  default     = "10.0.2.1"
}

variable "volume_size" {
  description = "Data volume size in GB"
  type        = number
  default     = 50
}
