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

######################################
##### Create Untrust route table #####
######################################

resource "oci_core_route_table" "untrust_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compute_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.public_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}

# ------ HA Routing Table for Hub VCN 
resource "oci_core_route_table" "ha_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compute_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.ha_routetable_display_name
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

resource "oci_core_route_table" "untrust_route_table_existing" {
  count          = local.use_existing_network ? 1 : 0
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = var.untrust_routetable_display_name_existing

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = var.igw_ocid
  }
}

resource "oci_core_route_table_attachment" "untrust_route_table_existing_attachment" {
  count          = local.use_existing_network ? 1 : 0
  subnet_id      = local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust_subnet[0].id
  route_table_id = element(oci_core_route_table.untrust_route_table_existing[*].id, 0)
}

resource "oci_core_route_table" "trust_route_table_existing" {
  count          = local.use_existing_network ? 1 : 0
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = var.trust_routetable_display_name_existing
}

resource "oci_core_route_table_attachment" "trust_route_table_existing_attachment" {
  count          = local.use_existing_network ? 1 : 0
  subnet_id      = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.management_subnet[0].id
  route_table_id = element(oci_core_route_table.trust_route_table_existing[*].id, 0)
}

resource "oci_core_route_table" "ha_route_table_existing" {
  count          = local.use_existing_network ? 1 : 0
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = var.ha_routetable_display_name_existing
}

resource "oci_core_route_table_attachment" "ha_route_table_existing_attachment" {
  count          = local.use_existing_network ? 1 : 0
  subnet_id      = local.use_existing_network ? var.ha_subnet_id : oci_core_subnet.management_subnet[0].id
  route_table_id = element(oci_core_route_table.ha_route_table_existing[*].id, 0)
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

# ------ Create Hub VCN Trust subnet
resource "oci_core_subnet" "trust_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.compute_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.trust_subnet_cidr_block
  display_name               = var.trust_subnet_display_name
  dns_label                  = var.trust_subnet_dns_label
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "true"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]

}

# ------ Create Hub VCN HA subnet 
resource "oci_core_subnet" "ha_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.compute_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.ha_subnet_cidr_block
  display_name               = var.ha_subnet_display_name
  route_table_id             = oci_core_vcn.hub[count.index].default_route_table_id
  dns_label                  = var.ha_subnet_dns_label
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "true"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Update Route Table for Trust Subnet
resource "oci_core_route_table_attachment" "update_inside_route_table" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
  route_table_id = oci_core_route_table.trust_route_table[count.index].id
}

# ------ Create Hub VCN Untrust subnet
resource "oci_core_subnet" "untrust_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.compute_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.untrust_subnet_cidr_block
  display_name               = var.untrust_subnet_display_name
  route_table_id             = oci_core_route_table.untrust_route_table[count.index].id
  dns_label                  = var.untrust_subnet_dns_label
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "false"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Create route table for backend to point to backend cluster ip (Hub VCN)
resource "oci_core_route_table" "trust_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub[0].id
  display_name   = var.private_routetable_display_name
}

# ------ Add Trust route table to Trust subnet (Hub VCN)
resource "oci_core_route_table_attachment" "trust_route_table_attachment" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
  route_table_id = oci_core_route_table.trust_route_table[count.index].id
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
# # ------ Create Cluster Trust Floating IP (Hub VCN)
# resource "oci_core_private_ip" "cluster_trust_ip" {
#   vnic_id      = data.oci_core_vnic_attachments.trust_attachments.vnic_attachments.0.vnic_id
#   display_name = "firewall_trust_secondary_private"
# }

# # ------ Create Cluster Untrust Floating IP (Hub VCN)
# resource "oci_core_private_ip" "cluster_untrust_ip" {
#   vnic_id      = data.oci_core_vnic_attachments.untrust_attachments.vnic_attachments.0.vnic_id
#   display_name = "firewall_untrust_secondary_private"
# }

# # frontend cluster ip 
# resource "oci_core_public_ip" "cluster_untrust_public_ip" {
#   count          = (var.use_existing_ip != "Create new IP") ? 0 : 1
#   compartment_id = var.compute_compartment_ocid

#   lifetime      = "RESERVED"
#   private_ip_id = oci_core_private_ip.cluster_untrust_ip.id
# }


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