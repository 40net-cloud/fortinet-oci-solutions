##########################
##### Create Hub VCN #####
##########################

resource "oci_core_vcn" "hub" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.vcn_cidr_block
  dns_label      = var.vcn_dns_label
  compartment_id = var.compute_compartment_ocid
  display_name   = var.vcn_display_name
}

###################################
##### Create Internet Gateway #####
###################################

resource "oci_core_internet_gateway" "igw" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compute_compartment_ocid
  display_name   = "Internet-Gateway"
  vcn_id         = oci_core_vcn.hub[count.index].id
  enabled        = "true"
}

##################################################
##### Create default route table for Hub VCN #####
##################################################

resource "oci_core_default_route_table" "default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.hub[count.index].default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}


# ------ Management Routing Table for Hub VCN 
resource "oci_core_route_table" "management_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compute_compartment_ocid
  vcn_id         = oci_core_vcn.hub[0].id
  display_name   = var.management_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}

resource "oci_core_route_table" "management_route_table_existing" {
  count          = local.use_existing_network ? 1 : 0
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = var.management_routetable_display_name_existing

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.igw_ocid
  }
}

resource "oci_core_route_table_attachment" "management_route_table_existing_attachment" {
  count          = local.use_existing_network ? 1 : 0
  subnet_id      = local.use_existing_network ? var.management_subnet_id : oci_core_subnet.management_subnet[0].id
  route_table_id = element(oci_core_route_table.management_route_table_existing[*].id, 0)
}


# ------ Get All Services Data Value 
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# ------ Create Hub VCN Public subnet
resource "oci_core_subnet" "management_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.compute_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.management_subnet_cidr_block
  display_name               = var.management_subnet_display_name
  route_table_id             = oci_core_route_table.management_route_table[count.index].id
  dns_label                  = var.management_subnet_dns_label
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "false"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "allow_all_security" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

##################################
#####  Create Security List  #####
##################################

resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id

  display_name = var.nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = "0.0.0.0/0"
}