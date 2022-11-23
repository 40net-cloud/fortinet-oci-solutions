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
variable "region" {
  description = "Oracle Cloud region"
}

##VCN and SUBNET ADDRESSESS
variable "vcn_cidr" {
  description = "Enter your VCN CIDR"
}

variable "vcn_ocid" {
  description = "Enter your VCN OCID"
}

variable "igw_ocid" {
  description = "Enter your Internet Gateway OCID"
}

variable "mgmt_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "mgmt_subnet_gateway" {
  default = "10.1.1.1"
}


variable "untrust_subnet_cidr" {
  default = "10.1.10.0/24"
}

variable "untrust_subnet_gateway" {
  default = "10.1.10.1"
}

variable "untrust_public_ip_lifetime" {
  default = "RESERVED"
  //or EPHEMERAL
}

variable "trust_subnet_cidr" {
  default = "10.1.100.0/24"
}

variable "trust_subnet_gateway" {
  default = "10.1.100.1"
}

variable "hb_subnet_cidr" {
  default = "10.1.200.0/24"
}

#FIREWALL IPs

#FLOATING/FAILOVER
variable "untrust_floating_private_ip" {
  default = "10.1.10.10"
}

variable "trust_floating_private_ip" {
  default = "10.1.100.10"
}


#ACTIVE NODE
variable "mgmt_private_ip_primary_a" {
  default = "10.1.1.2"
}

variable "untrust_private_ip_primary_a" {
  default = "10.1.10.2"
}

variable "trust_private_ip_primary_a" {
  default = "10.1.100.2"
}

variable "hb_private_ip_primary_a" {
  default = "10.1.200.2"
}

#PASSIVE NODE
variable "mgmt_private_ip_primary_b" {
  default = "10.1.1.20"
}

variable "untrust_private_ip_primary_b" {
  default = "10.1.10.20"
}

variable "trust_private_ip_primary_b" {
  default = "10.1.100.20"
}

variable "hb_private_ip_primary_b" {
  default = "10.1.200.20"
}

variable "vm_image_ocid" { 
  default =  "ocid1.image.oc1..aaaaaaaa7ijmjzxe7fplsbqvdnv7larynamky3w4rokln7ism5h6mdj27kiq"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaam7ewzrjbltqiarxukuk72v2lqkdtpqtwxqpszqqvrm7likfnpt5q" //byol
}

// Version
variable "mp_listing_resource_version" {
  default = "6.4.10_SR-IOV_Paravirtualized_Mode"
}
variable "instance_shape" {
  default = "VM.Standard2.4"
}

# Choose an Availability Domain (1,2,3)
variable "availability_domain-a" {
  default = "1"
}

variable "availability_domain-b" {
  default = "2"
}

variable "volume_size" {
  default = "50" //GB
}

variable "bootstrap_FortiGate-B" {
 default = "./userdata/bootstrap_FortiGate-B.tpl"
}

variable "bootstrap_FortiGate-A" {
 default = "./userdata/bootstrap_FortiGate-A.tpl"
}