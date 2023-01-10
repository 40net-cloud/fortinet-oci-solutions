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
  default =  "ocid1.image.oc1..aaaaaaaayzcupanu2u45tnky7yoiz6urk4awdisum4bhqjlzwoxk2o5xpcda"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaa4ehcyncbbmuotd6ede2lengq7uoash27s4hgwpzexsktsxanp6oa" //BYOL
}

// Version
variable "mp_listing_resource_version" {
  default = "7.2.1_Paravirtualized_Mode"
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
