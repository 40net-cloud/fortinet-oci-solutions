##############################################################################################################
## 1. NETWORK COMPONENTS
##############################################################################################################

##############################################################################################################
## 1.1 HUB VCN settings
##############################################################################################################

# Hub VCN name & CIDR
//resource "oci_core_virtual_network" "vcn" {
//  cidr_block     = var.vcn
//  compartment_id = var.compartment_ocid
//  display_name   = "${var.PREFIX}-vcn"
//  dns_label      = "fwbhub"
//}

	//if you want to point to an existing vcn, use data source
data "oci_core_vcn" "vcn" {
 vcn_id = var.vcn
}

//# Internet Gateway for Hub VCN
//resource "oci_core_internet_gateway" "igw" {
//  compartment_id = var.compartment_ocid
//  display_name   = "${var.PREFIX}-igw"
//  vcn_id         = oci_core_virtual_network.vcn.id
//}

	data "oci_core_internet_gateways" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
}

##############################################################################################################
## 1.2 LOAD BALANCER SUBNET (created in Hub VCN)
##############################################################################################################

# Load Balancer subnet settings
resource "oci_core_subnet" "lb_subnet" {
  cidr_block        = var.subnet["1"]
  display_name      = "${var.PREFIX}-lb"
  compartment_id    = var.compartment_ocid
  vcn_id            = data.oci_core_vcn.vcn.id
  route_table_id    = oci_core_route_table.lb_routetable.id
  security_list_ids = [data.oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.nlb_security_list.id]
  dhcp_options_id   = data.oci_core_vcn.vcn.default_dhcp_options_id
  dns_label         = "fwbloadbalancer"
}

# Route Table for network load balancer subnet
resource "oci_core_route_table" "lb_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-lb-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = var.igw_ocid
  }
}

# Security list for network load balancer subnet 
resource "oci_core_security_list" "nlb_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-nlb-security-list"

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

##############################################################################################################
## UNTRUSTED SUBNET Configuration
##############################################################################################################

# Untrusted subnet settings
resource "oci_core_subnet" "untrusted_subnet" {
  cidr_block        = var.subnet["2"]
  display_name      = "${var.PREFIX}-untrusted"
  compartment_id    = var.compartment_ocid
  vcn_id            = data.oci_core_vcn.vcn.id
  route_table_id    = oci_core_route_table.untrusted_routetable.id
  security_list_ids = [data.oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.untrusted_security_list.id]
  dhcp_options_id   = data.oci_core_vcn.vcn.default_dhcp_options_id
  dns_label         = "fwbuntrusted"
}

# Route table for Untrusted subnet

resource "oci_core_route_table" "untrusted_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-untrusted-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = var.igw_ocid

  }
}

# Security List for Untrusted Subnet

resource "oci_core_security_list" "untrusted_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-untrusted-security-list"

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

###############################
## TRUST NETWORK SETTINGS    ##
###############################

resource "oci_core_subnet" "trust_subnet" {
  cidr_block                 = var.subnet["3"]
  display_name               = "${var.PREFIX}-trusted"
  compartment_id             = var.compartment_ocid
  vcn_id                     = data.oci_core_vcn.vcn.id
  route_table_id             = oci_core_route_table.trust_routetable.id
  security_list_ids          = [data.oci_core_vcn.vcn.default_security_list_id, oci_core_security_list.trust_security_list.id]
  dhcp_options_id            = data.oci_core_vcn.vcn.default_dhcp_options_id
  dns_label                  = "trust"
  prohibit_public_ip_on_vnic = "true"
}

resource "oci_core_route_table" "trust_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-trust-routetable"
}

# Protocols are specified as protocol numbers.
# http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
resource "oci_core_security_list" "trust_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = data.oci_core_vcn.vcn.id
  display_name   = "${var.PREFIX}-trust-security-list"


  // allow outbound traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  // allow inbound traffic on all ports from network
  ingress_security_rules {
    protocol  = "all"
    source    = var.vcn_cidr
    stateless = false
  }
}



##############################################################################################################
## EXTERNAL NETWORK LOAD BALANCER Configuration
##############################################################################################################

# Load Balancer name & shape
resource "oci_network_load_balancer_network_load_balancer" "lb_external" {
  #Required
  depends_on     = [oci_core_instance.vm_fwb_b]
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-lb-untrusted"
  subnet_id      = oci_core_subnet.lb_subnet.id
  #Optional
  is_private     = false
  is_preserve_source_destination = true
}

# Network Load Balancer Listener
resource "oci_network_load_balancer_listener" "lb_external_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.lb_external_backend_set.name
  name                     = "${var.PREFIX}-lb-untrusted-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb_external.id
  port                     = 0
  protocol                 = "ANY"
}

# Network Load Balancer Backend Set
resource "oci_network_load_balancer_backend_set" "lb_external_backend_set" {
  health_checker {
    protocol = "TCP"
    port     = 8443
  }

  name                     = "${var.PREFIX}-untrusted-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb_external.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true
}

# Network Load Balancer Backends
resource "oci_network_load_balancer_backend" "lb_external_backend_fwba" {
  backend_set_name         = oci_network_load_balancer_backend_set.lb_external_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb_external.id
  port                     = 0
  ip_address               = var.fwba_ipaddress_port1
}

resource "oci_network_load_balancer_backend" "lb_external_backend_fwbb" {
  backend_set_name         = oci_network_load_balancer_backend_set.lb_external_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.lb_external.id
  port                     = 0
  ip_address               = var.fwbb_ipaddress_port1
}