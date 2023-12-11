##############################################################################################################
#
# FortiWeb Active/Active Load Balanced pair of standalone FortiWeb VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  default = "FortiWeb"
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
  default = "VM.Standard2.2"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaabns5i7dbr5rwxrkvbxlofsnn5gdvbe47qtfnqtl54sni3ltuxoga" //BYOL
}

//variable "mp_listing_resource_id" {
//default = "ocid1.image.oc1..aaaaaaaahzbjbsp22ixqkmj5nn2mr2mvknh2sqd27zqrscwndt5kwf5isleq"
//}

// Version
variable "mp_listing_resource_version" {
  default = "7.0.4"
}

// Image OCID
variable "vm_image_ocid" {
  default = "ocid1.image.oc1..aaaaaaaahzbjbsp22ixqkmj5nn2mr2mvknh2sqd27zqrscwndt5kwf5isleq"
}

// Cert use for SDN Connector setting
variable "cert" {
  type    = string
  default = "Fortinet_Factory"
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
    "2" = "172.16.140.16/28" # Untrusted
    "3" = "172.16.140.32/28" # Trusted
  }
}

variable "subnetmask" {
  type        = map(string)
  description = ""

  default = {
    "1" = "28" # Flexible Network Load Balancer
    "2" = "28" # Untrusted
    "3" = "28" # Trusted
  }
}

variable "gateway" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.140.1"  # Flexible Network Load Balancer
    "2" = "172.16.140.17" # Untrusted
    "3" = "172.16.140.33" #Trusted
  }
}

variable "fwba_ipaddress_port1" {
  type    = string
  default = "172.16.140.20" # Untrusted  
}

variable "fwbb_ipaddress_port1" {
  type    = string
  default = "172.16.140.21" # Untrusted   
}

variable "fwba_ipaddress_port2" {
  type    = string
  default = "172.16.140.40" # Trusted  
}

variable "fwbb_ipaddress_port2" {
  type    = string
  default = "172.16.140.41" # Trusted   
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