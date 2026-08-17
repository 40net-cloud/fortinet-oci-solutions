resource "oci_core_vcn" "fortiadc" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = var.vcn_display_name
  dns_label      = "fortiadc"
}

resource "oci_core_internet_gateway" "fortiadc" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fortiadc[0].id
  display_name   = "${var.vm_display_name}-internet-gateway"
  enabled        = true
}

resource "oci_core_route_table" "frontend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fortiadc[0].id
  display_name   = "${var.vm_display_name}-frontend-routes"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.fortiadc[0].id
  }
}

resource "oci_core_route_table" "backend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fortiadc[0].id
  display_name   = "${var.vm_display_name}-backend-routes"
}

resource "oci_core_security_list" "frontend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fortiadc[0].id
  display_name   = "${var.vm_display_name}-frontend-empty-security-list"
}

resource "oci_core_security_list" "backend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.fortiadc[0].id
  display_name   = "${var.vm_display_name}-backend-empty-security-list"
}

resource "oci_core_subnet" "frontend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.fortiadc[0].id
  cidr_block                 = var.frontend_subnet_cidr
  display_name               = "${var.vm_display_name}-frontend-subnet"
  dns_label                  = "frontend"
  route_table_id             = oci_core_route_table.frontend[0].id
  security_list_ids          = [oci_core_security_list.frontend[0].id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "backend" {
  count = local.use_existing_network ? 0 : 1

  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.fortiadc[0].id
  cidr_block                 = var.backend_subnet_cidr
  display_name               = "${var.vm_display_name}-backend-subnet"
  dns_label                  = "backend"
  route_table_id             = oci_core_route_table.backend[0].id
  security_list_ids          = [oci_core_security_list.backend[0].id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_network_security_group" "frontend" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.vm_display_name}-frontend-nsg"
}

resource "oci_core_network_security_group_security_rule" "frontend_egress" {
  network_security_group_id = oci_core_network_security_group.frontend.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "management_https" {
  network_security_group_id = oci_core_network_security_group.frontend.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.management_cidr

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "management_ssh" {
  network_security_group_id = oci_core_network_security_group.frontend.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.management_cidr

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "client_traffic" {
  network_security_group_id = oci_core_network_security_group.frontend.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.client_ingress_cidr

  tcp_options {
    destination_port_range {
      min = var.client_port_min
      max = var.client_port_max
    }
  }
}

resource "oci_core_network_security_group" "backend" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.vm_display_name}-backend-nsg"
}

resource "oci_core_network_security_group_security_rule" "backend_ingress" {
  network_security_group_id = oci_core_network_security_group.backend.id
  direction                 = "INGRESS"
  protocol                  = "all"
  source                    = var.backend_subnet_cidr
}

resource "oci_core_network_security_group_security_rule" "backend_egress" {
  network_security_group_id = oci_core_network_security_group.backend.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}
