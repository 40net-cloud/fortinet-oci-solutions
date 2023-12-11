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

variable "trust_subnet_cidr" {
  default = "10.1.100.0/24"
}

variable "trust_subnet_gateway" {
  default = "10.1.100.1"
}

#FIREWALL IPs

variable "untrust_private_ip" {
  default = "10.1.1.10"
}

variable "trust_private_ip" {
  default = "10.1.100.10"
}

variable "vm_image_ocid" {
  default = "ocid1.image.oc1..aaaaaaaa4d4x7cmgq4yimk6eg3kydwelpuctbxracvqcqktgza7zpmujan2a"
}

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaa6d5wbjlrlihw7l33nvdso74lv2s66snabevr33awotpgjownggiq" //byol
}

// Version
variable "mp_listing_resource_version" {
  default = "7.2.3_(_X64_)"
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
