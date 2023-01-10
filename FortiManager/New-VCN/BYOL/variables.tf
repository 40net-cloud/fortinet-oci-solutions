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
  default = "10.1.0.0/16"
}

variable "untrust_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "untrust_subnet_gateway" {
  default = "10.1.1.1"
}

#FIREWALL IPs

variable "untrust_private_ip" {
  default = "10.1.1.10"
}

variable "vm_image_ocid" { 
  default =  "ocid1.image.oc1..aaaaaaaatx3hyn3hja2aqj4tvpdmlhps3yebdrtxp3m6svihlq7cfubehphq"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaawpkjzjrzqhd6m4q6j6qfkwsiqaqnv5f5juup6z2lvyg56wjbcbyq" //BYOL
}

// Version
variable "mp_listing_resource_version" {
  default = "6.4.10_Paravirtualized_Mode"
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

variable "bootstrap_FortiGate" {
 default = "./userdata/bootstrap_FortiGate.tpl"
}

variable "untrust_public_ip_lifetime" {
  default = "RESERVED"
  //or EPHEMERAL
}
