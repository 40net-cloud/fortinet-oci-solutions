#Variables declared in this file must be declared in the marketplace.yaml

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {}
variable "user_ocid" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "fingerprint" {
  default = ""
}
variable "region" {
  description = "Oracle Cloud region"
}
############################
#  Marketplace Image      #
############################

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = true
}

############################
#  Compute Configuration   #
############################

variable "vm_display_name" {
  description = "Instance Name"
  default     = "FortiGate"
}

variable "vm_flex_shape_ocpus" {
  description = "Flex Shape OCPUs"
  default     = 4
}

variable "vm_compute_shape_arm" {
  description = "Compute shape to use when CPU type is ARM64"
  type        = string
  default     = ""
}

variable "vm_compute_shape_x64" {
  description = "Compute shape to use when CPU type is X64"
  type        = string
  default     = ""
}

variable "availability_domain_number" {
  type        = number
  description = "Optional AD number input"
  default     = 1
}

variable "availability_domain_name_1" {
  description = "Availability Domain for FortiGate-VM"
}

variable "license_type" {
  description = "License type, e.g. BYOL or PAYGO (like 'PAYGO 4 OCPUs')"
  type        = string
}

variable "ocpu_count" {
  description = "Number of OCPUs for Flex shapes"
  type        = number
  nullable    = true
  default     = null
}

variable "memory_in_gbs" {
  description = "Amount of memory (GB) for Flex shapes"
  type        = number
  nullable    = true
  default     = null
}

variable "cpu_type" {
  type = string
  validation {
    condition     = contains(["X64", "ARM64"], var.cpu_type)
    error_message = "cpu_type must be X64 or ARM64"
  }
}

variable "fortios_version" {
  type = string
  validation {
    condition     = contains(["6.4.13", "7.0.17", "7.2.11", "7.4.8", "7.6.3", "7.6.4"], var.fortios_version)
    error_message = "Only supported FortiOS versions are allowed"
  }
}

variable "instance_launch_options_network_type" {
  description = "NIC Attachment Type"
  default     = "PARAVIRTUALIZED"
}

############################
#  Network Configuration   #
############################

variable "network_strategy" {
  default = "Create New VCN and Subnet"
}

variable "vcn_id" {
  default = ""
}

variable "vcn_display_name" {
  description = "VCN Name"
  default     = "FortiGate-Hub-VCN"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  default     = "192.168.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS Label"
  default     = "ha"
}

variable "subnet_span" {
  description = "Choose between regional and AD specific subnets"
  default     = "Regional Subnet"
}

variable "management_subnet_id" {
  default = ""
}

variable "management_subnet_display_name" {
  description = "Management Subnet Name"
  default     = "mgmt-subnet"
}

variable "management_subnet_cidr_block" {
  description = "Management Subnet CIDR"
  default     = "192.168.1.0/24"
}

variable "management_subnet_dns_label" {
  description = "Management Subnet DNS Label"
  default     = "management"
}

variable "trust_subnet_id" {
  default = ""
}

variable "trust_subnet_display_name" {
  description = "Trust Subnet Name"
  default     = "trust-subnet"
}

variable "trust_subnet_cidr_block" {
  description = "Trust Subnet CIDR"
  default     = "192.168.2.0/24"
}

variable "trust_subnet_dns_label" {
  description = "Trust Subnet DNS Label"
  default     = "trust"
}

variable "untrust_subnet_id" {
  default = ""
}

variable "untrust_subnet_display_name" {
  description = "Firewall Untrust Subnet Name"
  default     = "untrust-subnet"
}

variable "untrust_subnet_cidr_block" {
  description = "Firewall Untrust Subnet CIDR"
  default     = "192.168.3.0/24"
}

variable "untrust_subnet_dns_label" {
  description = "Untrust Subnet DNS Label"
  default     = "untrust"
}

############################
# Additional Configuration #
############################

variable "compute_compartment_ocid" {
  description = "Compartment where Compute and Marketplace subscription resources will be created"
}

variable "nsg_whitelist_ip" {
  description = "Network Security Groups - Whitelisted CIDR block for ingress communication: Enter 0.0.0.0/0 or <your IP>/32"
  default     = "0.0.0.0/0"
}

variable "nsg_display_name" {
  description = "Network Security Groups - Name"
  default     = "cluster-security-group"
}

variable "public_routetable_display_name" {
  description = "Public route table Name"
  default     = "Untrust-Route-Table"
}

variable "management_routetable_display_name" {
  description = "Management route table Name"
  default     = "Management-Route-Table"
}

variable "management_routetable_display_name_existing" {
  description = "Management route table Name"
  default     = "Management-Route-Table"
}

variable "untrust_routetable_display_name_existing" {
  description = "Untrust route table Name"
  default     = "Untrust-Route-Table-Existing"
}

variable "trust_routetable_display_name_existing" {
  description = "Untrust route table Name"
  default     = "Untrust-Route-Table-Existing"
}

variable "management_route_table_existing_attachment" {
  description = "Management route table existing attachment Name"
  default     = "Management-Route-Table-Existing-Attachment"
}

variable "private_routetable_display_name" {
  description = "Private route table Name"
  default     = "Trust-Route-Table"
}

variable "use_existing_ip" {
  description = "Use an existing permanent public ip"
  default     = "Create new IP"
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type"
  default     = "fortigate-drg-ha"
}

variable "template_version" {
  description = "Template version"
  default     = "20210701"
}

variable "igw_ocid" {
  description = "Internet Gateway OCID"
  default     = ""
}

######################
#    Enum Values     #   
######################
variable "network_strategy_enum" {
  type = map(any)
  default = {
    CREATE_NEW_VCN_SUBNET   = "Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET = "Use Existing VCN and Subnet"
  }
}

variable "subnet_type_enum" {
  type = map(any)
  default = {
    transit_subnet    = "Private Subnet"
    MANAGEMENT_SUBENT = "Public Subnet"
  }
}

variable "nsg_config_enum" {
  type = map(any)
  default = {
    BLOCK_ALL_PORTS = "Block all ports"
    OPEN_ALL_PORTS  = "Open all ports"
    CUSTOMIZE       = "Customize ports - Post deployment"
  }
}

variable "bootstrap_vm-a" {
  default = "./cloudinit/bootstrap_vm-a.tpl"
}

######################
#    Static Values     #   
######################
#ACTIVE NODE
variable "mgmt_private_ip_primary_a" {
  description = "Primary Firewall Mgmt Interface Private IP"
  default     = "192.168.1.10"
}

variable "untrust_private_ip_primary_a" {
  description = "Primary Firewall Untrust Interface Private IP"
  default     = "192.168.3.10"
}

variable "trust_private_ip_primary_a" {
  description = "Primary Firewall Trust Interface Private IP"
  default     = "192.168.2.10"
}

#PASSIVE NODE
variable "mgmt_private_ip_primary_b" {
  description = "Secondary Firewall Mgmt Interface Private IP"
  default     = "192.168.1.20"
}

variable "untrust_private_ip_primary_b" {
  description = "Secondary Firewall Untrust Interface Private IP"
  default     = "192.168.3.20"
}

variable "trust_private_ip_primary_b" {
  description = "Secondary Firewall Trust Interface Private IP"
  default     = "192.168.2.20"
}


variable "untrust_floating_private_ip" {
  description = "Firewall Untrust Interface Floating Private IP"
  default     = "192.168.3.30"
}

variable "trust_floating_private_ip" {
  description = "Firewall Trust Interface Floating Private IP"
  default     = "192.168.2.30"
}

variable "mgmt_subnet_gateway" {
  description = "Mgmt Subnet Default Gateway IP"
  default     = "192.168.1.1"
}

variable "trust_subnet_gateway" {
  description = "Trust Subnet Default Gateway IP"
  default     = "192.168.2.1"
}

variable "untrust_subnet_gateway" {
  description = "Untrust Subnet Default Gateway IP"
  default     = "192.168.3.1"
}

variable "untrust_public_ip_lifetime" {
  description = "Public IP Address Reservation Type"
  default     = "RESERVED"
}

variable "volume_size" {
  description = "Firewall VM Block Volume Attachment Size in GB"
  default     = "50" //GB
}
