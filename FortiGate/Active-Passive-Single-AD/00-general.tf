##############################################################################################################
#
# FortiGate Terraform deployment
# Active Passive High Availability Single AD in OCI
#
##############################################################################################################

# Prefix for all resources created for this deployment in OCI
variable "tag_name_prefix" {
  description = "Provide a common tag prefix value that will be used in the name tag for all resources"
  default     = "HA-FGT"
}


##############################################################################################################
# Terraform state
##############################################################################################################

terraform {
  required_version = ">= 0.12"
}

##############################################################################################################
# Deployment in OCI in v.6.4.2.
##############################################################################################################
# Access and secret keys to your environment
variable "tenancy_ocid" {
  default = ""
}
variable "compartment_ocid" {
  default = ""
}

variable "region" {
  #default = "uk-london-1"
  default = "eu-frankfurt-1"
  #default = "me-jeddah-1"
  #default = "eu-amsterdam-1"
}

# Choose whether to deploy each Firewall in a different Fault Domain
# Choices are: FAULT-DOMAIN-1, FAULT-DOMAIN-2 and FAULT-DOMAIN-3
variable "vm-a_fault_domain" {
  default = "FAULT-DOMAIN-1"
}
variable "vm-b_fault_domain" {
  default = "FAULT-DOMAIN-2"
}

###################################
# PROVIDER OCI
###################################
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  region = var.region
}

##############################################################################################################
# SUBNETS in OCI
##############################################################################################################

##VCN and SUBNET ADDRESSES
### mgmt
variable "vcn_cidr" {
  default = "10.15.0.0/16"
}

variable "mgmt_subnet_cidr" {
  default = "10.15.1.0/24"
}

variable "mgmt_subnet_gateway" {
  default = "10.15.1.1"
}

### untrust - wan
variable "untrust_subnet_cidr" {
  default = "10.15.10.0/24"
}

variable "untrust_subnet_gateway" {
  default = "10.15.10.1"
}

variable "untrust_public_ip_lifetime" {
  default = "RESERVED"
  //or EPHEMERAL
}

### trust - lan
variable "trust_subnet_cidr" {
  default = "10.15.100.0/24"
}

variable "trust_subnet_gateway" {
  default = "10.15.100.1"
}

variable "hb_subnet_cidr" {
  default = "10.15.200.0/24"
}

##############################################################################################################
# FIREWALL IPs
##############################################################################################################
### FLOATING/FAILOVER
variable "untrust_floating_private_ip" {
  default = "10.15.10.10"
}

variable "trust_floating_private_ip" {
  default = "10.15.100.10"
}


#ACTIVE NODE
variable "mgmt_private_ip_primary_a" {
  default = "10.15.1.2"
}

variable "untrust_private_ip_primary_a" {
  default = "10.15.10.2"
}

variable "trust_private_ip_primary_a" {
  default = "10.15.100.2"
}

variable "hb_private_ip_primary_a" {
  default = "10.15.200.2"
}

#PASSIVE NODE
variable "mgmt_private_ip_primary_b" {
  default = "10.15.1.20"
}

variable "untrust_private_ip_primary_b" {
  default = "10.15.10.20"
}

variable "trust_private_ip_primary_b" {
  default = "10.15.100.20"
}

variable "hb_private_ip_primary_b" {
  default = "10.15.200.20"
}

##############################################################################################################
# IMAGES
##############################################################################################################

// variable "vm_image_ocid" {
//   default = "PIC or custom image OCID"
// }

variable "vm_image_ocid" {
  type = map

  default = {   
   eu-frankfurt-1 = "ocid1.image.oc1..aaaaaaaa7nzyf5boguhfwaj7v6bdy3endovdsvzy2i7rnsavq2367krdazsq"
}
}

variable "instance_shape" {
  default = "VM.Standard2.4"
}

# Choose an Availability Domain (1,2,3)
variable "availability_domain" {
  default = "1"
}

variable "volume_size" {
  default = "50" //GB
}

variable "license_vm-a" {
  default = "./fgt1.lic"
}

variable "license_vm-b" {
  default = "./fgt2.lic"
}

variable "sdn_oci_certificate_name" {
  default = "Fortinet_Factory"
}
