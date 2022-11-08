##############################################################################################################
#
# DRGv2 Hub and Spoke traffic inspection
# FortiGate Active/Active Load Balanced pair of standalone FortiGate VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  description = "Added name to each deployed resource"
}

variable "region" {
  description = "Oracle Cloud region"
}

##############################################################################################################
# Oracle Cloud configuration
##############################################################################################################

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {
  default = ""
}
variable "private_key_path" {
  default = ""
}
variable "fingerprint" {
  default = ""
}

##############################################################################################################
# FortiWeb Instance Type
##############################################################################################################
variable "instance_shape" {
  type    = string
  default = "VM.Standard.E3.Flex"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaabns5i7dbr5rwxrkvbxlofsnn5gdvbe47qtfnqtl54sni3ltuxoga" //byol
}

variable "mp_listing_resource_id" {
  default = "ocid1.image.oc1..aaaaaaaasqn4zerim4l4mmmilnmcj5npl7mam7abpzekiwsyoc5b7plevula"
}

// Version
variable "mp_listing_resource_version" {
  default = "6.3.4"
}

// Image OCID
variable "vm_image_ocid" {
  default = "ocid1.image.oc1..aaaaaaaao56si7kqaq7tcx46avgetirzhpah37752lq47ndwgi33jhwzoj3q"
}


// Cert use for SDN Connector setting
variable "cert" {
  type    = string
  default = "Fortinet_Factory"
}

##############################################################################################################
# FortiWeb License Type
##############################################################################################################

// license file location for fwb a
variable "fwb_byol_license_a" {
  // Change to your own path
  type    = string
  default = ""
}

// license file location for fwb b
variable "fwb_byol_license_b" {
  // Change to your own path
  type    = string
  default = ""
}

// Flex-VM license token for fwb a
variable "fwb_byol_flexvm_license_a" {
  // Change to your own path
  type    = string
  default = ""
}

// Flex-VM license token for fwb b
variable "fwb_byol_flexvm_license_b" {
  // Change to your own path
  type    = string
  default = ""
}

##############################################################################################################
# VCN and SUBNET ADDRESSESS
##############################################################################################################

variable "vcn" {
  default = "172.16.140.0/22"
}

variable "subnet" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.140.0/28"  # Flexible Network Load Balancer
    "2" = "172.16.140.32/28" # Untrusted
    "3" = "172.16.144.0/26" # Untrusted
  }
}

variable "subnetmask" {
  type        = map(string)
  description = ""

  default = {
    "1" = "28" # Flexible Network Load Balancer
    "2" = "28" # Untrusted
  }
}

variable "gateway" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.140.1"  # Flexible Network Load Balancer
    "2" = "172.16.140.33" # Untrusted
  }
}

variable "spoke1vm_ipaddress" {
  type = string
  default = "172.16.144.10" # Spoke1-VM  
}

variable "fwb_ipaddress_a" {
  type = string
  default = "172.16.140.35" # Untrusted  
}

variable "fwb_ipaddress_b" {
  type = string
  default = "172.16.140.36" # Untrusted   
}

variable "vcn_cidr_spoke1" {
  type    = string
  default = "172.16.144.0/24"
}

# Choose an Availability Domain (1,2,3)
variable "availability_domain" {
  type    = string
  default = "1"
}

variable "availability_domain2" {
  type    = string
  default = "2"
}

variable "volume_size" {
  type    = string
  default = "50" //GB; you can modify this, can't less than 50
}

variable "load_balancer_shape" {
  type    = string
  default = "10Mbps" //GB; you can modify this, can't less than 50
}

variable "spoke1vm_image_ocid" {
  default = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaoffnm7opezqbhzln3u4lzv6ujteag5h7oxcsio3kr35sp7mlamcq"
}
