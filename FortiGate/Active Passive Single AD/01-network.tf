##############################################################################################################
#
# OCI Fortigate HA Single AD deployment
# FortiGate setup with Active/Passice in Single AD
#
##############################################################################################################

##############################################################################################################
# VCN
##############################################################################################################

# Get a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

resource "oci_core_virtual_network" "my_vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "my-vcn"
  dns_label      = "myvcn"
}

//if you want to point to an existing vcn, use data source
// data "oci_core_virtual_networks" "my_vcn" {
//   compartment_id = "${var.compartment_ocid}"
// }

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "igw"
  vcn_id         = oci_core_virtual_network.my_vcn.id
}

### Security Group and security list
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "security-list"

  // allow outbound traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }
  // allow inbound traffic on all ports from network
  ingress_security_rules {
    protocol  = "all"
    source    = "0.0.0.0/0"
    stateless = false
  }
}

resource "oci_core_network_security_group" "all_network_security_group" {
    #Required
    compartment_id = var.compartment_ocid
    vcn_id = oci_core_virtual_network.my_vcn.id
}

resource "oci_core_network_security_group_security_rule" "all_egress_network_security_group_security_rule" {
    #Required
    network_security_group_id = oci_core_network_security_group.all_network_security_group.id
    direction = "EGRESS"
    protocol = "all"

    #Optional
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
}

resource "oci_core_network_security_group_security_rule" "all_ingress_network_security_group_security_rule" {
#Required
    network_security_group_id = oci_core_network_security_group.all_network_security_group.id
    direction = "INGRESS"
    protocol = "all"

    #Optional
    source = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
}


##############################################################################################################
# MGMT settings and RT
##############################################################################################################

# Route Tables
resource "oci_core_route_table" "mgmt_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "mgmt-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# mgmt subnet
resource "oci_core_subnet" "mgmt_subnet" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  cidr_block          = var.mgmt_subnet_cidr
  display_name        = "management"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.my_vcn.id
  route_table_id      = oci_core_route_table.mgmt_routetable.id
  security_list_ids   = [oci_core_virtual_network.my_vcn.default_security_list_id, oci_core_security_list.security_list.id]
  dhcp_options_id     = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  dns_label           = "mgmt"
}


############################################################################################################################################################
## TRUST/LAN NETWORK SETTINGS and RT 
############################################################################################################################################################

resource "oci_core_route_table" "trust_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "trust-routetable"
}

resource "oci_core_subnet" "trust_subnet" {
  availability_domain        = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  cidr_block                 = var.trust_subnet_cidr
  display_name               = "trust"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.trust_routetable.id
  security_list_ids          = [oci_core_virtual_network.my_vcn.default_security_list_id,oci_core_security_list.security_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  dns_label                  = "trust"
  prohibit_public_ip_on_vnic = "true"
}

############################################################################################################################################################
## UNTRUST/WAN NETWORK SETTINGS and RT 
############################################################################################################################################################

resource "oci_core_route_table" "untrust_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "untrust-routetable"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_subnet" "untrust_subnet" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  cidr_block          = var.untrust_subnet_cidr
  display_name        = "untrust"
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_virtual_network.my_vcn.id
  route_table_id      = oci_core_route_table.untrust_routetable.id
  security_list_ids   = [oci_core_virtual_network.my_vcn.default_security_list_id,oci_core_security_list.security_list.id]
  dhcp_options_id     = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  dns_label           = "untrust"
}

############################################################################################################################################################
## HEARTBEAT NETWORK SETTINGS and RT 
############################################################################################################################################################

resource "oci_core_route_table" "hb_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.my_vcn.id
  display_name   = "hb-routetable"
}

resource "oci_core_subnet" "hb_subnet" {
  availability_domain        = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1],"name")
  cidr_block                 = var.hb_subnet_cidr
  display_name               = "hb"
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.my_vcn.id
  route_table_id             = oci_core_route_table.hb_routetable.id
  security_list_ids          = [oci_core_virtual_network.my_vcn.default_security_list_id,oci_core_security_list.security_list.id]
  dhcp_options_id            = oci_core_virtual_network.my_vcn.default_dhcp_options_id
  dns_label                  = "hb"
  prohibit_public_ip_on_vnic = "true"
}
