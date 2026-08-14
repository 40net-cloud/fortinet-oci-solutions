resource "oci_core_vcn" "fortiweb" {
  count = local.use_existing_vcn ? 0 : 1

  compartment_id = var.network_compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = "${var.prefix}-vcn"
  dns_label      = "fwbvcn"
}

locals {
  selected_vcn_id = local.use_existing_vcn ? (
    data.oci_core_vcn.existing[0].id
  ) : oci_core_vcn.fortiweb[0].id

  selected_vcn_cidr = local.use_existing_vcn ? (
    data.oci_core_vcn.existing[0].cidr_block
  ) : var.vcn_cidr_block

  selected_default_dhcp_options_id = local.use_existing_vcn ? (
    data.oci_core_vcn.existing[0].default_dhcp_options_id
  ) : oci_core_vcn.fortiweb[0].default_dhcp_options_id
}

resource "oci_core_internet_gateway" "fortiweb" {
  count = local.use_existing_vcn ? 0 : 1

  compartment_id = var.network_compartment_ocid
  display_name   = "${var.prefix}-igw"
  vcn_id         = local.selected_vcn_id
  enabled        = true
}

locals {
  selected_igw_id = local.use_existing_vcn ? (
    var.existing_igw_ocid
  ) : oci_core_internet_gateway.fortiweb[0].id
}

resource "oci_core_route_table" "untrust" {
  depends_on = [terraform_data.validate_network]

  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-untrust-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = local.selected_igw_id
  }
}

resource "oci_core_route_table" "trust" {
  depends_on = [terraform_data.validate_network]

  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-trust-rt"
}

resource "oci_core_security_list" "untrust" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-untrust-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "all"
    source    = var.application_ingress_cidr
    stateless = false
  }

  ingress_security_rules {
    protocol  = "6"
    source    = var.admin_ingress_cidr
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol  = "6"
    source    = var.admin_ingress_cidr
    stateless = false

    tcp_options {
      min = 8443
      max = 8443
    }
  }

  ingress_security_rules {
    protocol  = "1"
    source    = var.admin_ingress_cidr
    stateless = false
  }
}

resource "oci_core_security_list" "trust" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-trust-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "all"
    source    = local.selected_vcn_cidr
    stateless = false
  }
}

resource "oci_core_subnet" "untrust" {
  depends_on = [terraform_data.validate_network]

  cidr_block                 = var.untrust_subnet_cidr
  display_name               = "${var.prefix}-untrust-subnet"
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = local.selected_vcn_id
  route_table_id             = oci_core_route_table.untrust.id
  security_list_ids          = [oci_core_security_list.untrust.id]
  dhcp_options_id            = local.selected_default_dhcp_options_id
  dns_label                  = "fwbuntrust"
  prohibit_public_ip_on_vnic = !var.assign_public_ip
}

resource "oci_core_subnet" "trust" {
  depends_on = [terraform_data.validate_network]

  cidr_block                 = var.trust_subnet_cidr
  display_name               = "${var.prefix}-trust-subnet"
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = local.selected_vcn_id
  route_table_id             = oci_core_route_table.trust.id
  security_list_ids          = [oci_core_security_list.trust.id]
  dhcp_options_id            = local.selected_default_dhcp_options_id
  dns_label                  = "fwbtrust"
  prohibit_public_ip_on_vnic = true
}

