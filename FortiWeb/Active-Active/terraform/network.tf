resource "oci_core_vcn" "fortiweb" {
  count = local.create_new_network ? 1 : 0

  compartment_id = var.network_compartment_ocid
  cidr_block     = var.vcn_cidr_block
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
}

locals {
  selected_vcn_id = local.use_existing_network ? (
    data.oci_core_vcn.existing[0].id
  ) : oci_core_vcn.fortiweb[0].id

  selected_vcn_cidr = local.use_existing_network ? (
    data.oci_core_vcn.existing[0].cidr_block
  ) : var.vcn_cidr_block

  selected_default_dhcp_options_id = local.use_existing_network ? (
    data.oci_core_vcn.existing[0].default_dhcp_options_id
  ) : oci_core_vcn.fortiweb[0].default_dhcp_options_id

  selected_lb_subnet_id        = local.use_existing_network ? var.lb_subnet_id : oci_core_subnet.lb[0].id
  selected_untrust_subnet_id   = local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust[0].id
  selected_untrust_subnet_cidr = local.use_existing_network ? data.oci_core_subnet.untrust_existing[0].cidr_block : var.untrust_subnet_cidr
  selected_untrust_gateway_ip  = local.use_existing_network ? data.oci_core_subnet.untrust_existing[0].virtual_router_ip : oci_core_subnet.untrust[0].virtual_router_ip
}

resource "oci_core_internet_gateway" "fortiweb" {
  count = local.create_new_network ? 1 : 0

  compartment_id = var.network_compartment_ocid
  display_name   = "${var.prefix}-igw"
  vcn_id         = local.selected_vcn_id
  enabled        = true
}

locals {
  selected_igw_id = local.use_existing_network ? (
    null
  ) : oci_core_internet_gateway.fortiweb[0].id
}

resource "oci_core_route_table" "lb" {
  count      = local.create_new_network ? 1 : 0
  depends_on = [terraform_data.validate_network]

  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-lb-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = local.selected_igw_id
  }
}

resource "oci_core_route_table" "untrust" {
  count      = local.create_new_network ? 1 : 0
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

resource "oci_core_security_list" "lb" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.selected_vcn_id
  display_name   = "${var.prefix}-lb-security-list"

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

  # The NLB preserves the original source address, so backend application
  # traffic must be allowed from the configured client CIDR.
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

resource "oci_core_subnet" "lb" {
  count      = local.create_new_network ? 1 : 0
  depends_on = [terraform_data.validate_network]

  cidr_block                 = var.lb_subnet_cidr
  display_name               = var.lb_subnet_display_name
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = local.selected_vcn_id
  route_table_id             = oci_core_route_table.lb[0].id
  security_list_ids          = [oci_core_security_list.lb.id]
  dhcp_options_id            = local.selected_default_dhcp_options_id
  dns_label                  = var.lb_subnet_dns_label
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "untrust" {
  count      = local.create_new_network ? 1 : 0
  depends_on = [terraform_data.validate_network]

  cidr_block                 = var.untrust_subnet_cidr
  display_name               = var.untrust_subnet_display_name
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = local.selected_vcn_id
  route_table_id             = oci_core_route_table.untrust[0].id
  security_list_ids          = [oci_core_security_list.untrust.id]
  dhcp_options_id            = local.selected_default_dhcp_options_id
  dns_label                  = var.untrust_subnet_dns_label
  prohibit_public_ip_on_vnic = !var.assign_public_ip
}

resource "oci_network_load_balancer_network_load_balancer" "external" {
  count = local.matched_package != null ? 1 : 0

  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}-public-nlb"
  subnet_id      = local.selected_lb_subnet_id

  is_private                     = false
  is_preserve_source_destination = true
}

resource "oci_network_load_balancer_backend_set" "external" {
  count = length(oci_network_load_balancer_network_load_balancer.external)

  name                     = "${var.prefix}-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external[0].id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true

  health_checker {
    protocol = "TCP"
    port     = var.health_check_port
  }
}

resource "oci_network_load_balancer_listener" "external" {
  count = length(oci_network_load_balancer_network_load_balancer.external)

  default_backend_set_name = oci_network_load_balancer_backend_set.external[0].name
  name                     = "${var.prefix}-any-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external[0].id
  port                     = 0
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend" "fwba" {
  count = length(oci_network_load_balancer_network_load_balancer.external)

  depends_on = [
    oci_core_instance.fwba
  ]

  backend_set_name         = oci_network_load_balancer_backend_set.external[0].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external[0].id
  port                     = 0
  ip_address               = var.fwba_untrust_ip
}

resource "oci_network_load_balancer_backend" "fwbb" {
  count = length(oci_network_load_balancer_network_load_balancer.external)

  depends_on = [
    oci_core_instance.fwbb
  ]

  backend_set_name         = oci_network_load_balancer_backend_set.external[0].name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external[0].id
  port                     = 0
  ip_address               = var.fwbb_untrust_ip
}
