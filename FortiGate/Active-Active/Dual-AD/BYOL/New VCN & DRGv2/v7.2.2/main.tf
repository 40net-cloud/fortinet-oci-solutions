##############################################################################################################
#
# DRGv2 Hub and Spoke traffic inspection
# FortiGate Active/Active Load Balanced pair of standalone FortiGate VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

##############################################################################################################
## VCN
##############################################################################################################

resource "oci_core_virtual_network" "vcn" {
  cidr_block     = var.vcn
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-vcn"
  dns_label      = "fgthub"
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-igw"
  vcn_id         = oci_core_virtual_network.vcn.id
}

##############################################################################################################
## Flexible Network Load Balancer NETWORK
##############################################################################################################

resource "oci_core_subnet" "nlb_subnet" {
  cidr_block        = var.subnet["1"]
  display_name      = "${var.PREFIX}-nlb"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  route_table_id    = oci_core_route_table.nlb_routetable.id
  security_list_ids = ["${oci_core_virtual_network.vcn.default_security_list_id}", "${oci_core_security_list.untrusted_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  dns_label         = "fgtloadbalancer"
}

resource "oci_core_route_table" "nlb_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-nlb-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

##############################################################################################################
## UNTRUSTED NETWORK
##############################################################################################################

resource "oci_core_subnet" "untrusted_subnet" {
  cidr_block        = var.subnet["2"]
  display_name      = "${var.PREFIX}-untrusted"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  route_table_id    = oci_core_route_table.untrusted_routetable.id
  security_list_ids = ["${oci_core_virtual_network.vcn.default_security_list_id}", "${oci_core_security_list.untrusted_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  dns_label         = "fgtuntrusted"
}

resource "oci_core_route_table" "untrusted_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-untrusted-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

resource "oci_core_security_list" "untrusted_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-untrusted-security-list"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound http (port 80) traffic
  ingress_security_rules {
    protocol = "6" // tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  // allow inbound http (port 443) traffic
  ingress_security_rules {
    protocol = "6" // tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

  // allow inbound ssh traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
  }
}

##############################################################################################################
## TRUSTED NETWORK
##############################################################################################################

resource "oci_core_subnet" "trusted_subnet" {
  cidr_block     = var.subnet["3"]
  display_name   = "${var.PREFIX}-trusted"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
#  route_table_id             = "${oci_core_route_table.trusted_routetable.id}"
  security_list_ids          = ["${oci_core_virtual_network.vcn.default_security_list_id}", "${oci_core_security_list.trusted_security_list.id}"]
  dhcp_options_id            = oci_core_virtual_network.vcn.default_dhcp_options_id
  dns_label                  = "fgttrusted"
  prohibit_public_ip_on_vnic = true
}

// route table attachment
#resource "oci_core_route_table_attachment" "trust_route_table_attachment" {
#  subnet_id      = oci_core_subnet.trusted_subnet.id
#  route_table_id = oci_core_route_table.trusted_routetable.id
#}

resource "oci_core_security_list" "trusted_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "fgt-internal-security-list"

  // allow outbound tcp traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound http (port 80) traffic
  ingress_security_rules {
    protocol = "all" // tcp
    source   = "0.0.0.0/0"
  }
}

##############################################################################################################
## SPOKE NETWORK
##############################################################################################################

resource "oci_core_virtual_network" "vcn_spoke1" {
  cidr_block     = var.vcn_cidr_spoke1
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-vcn-spoke1"
  dns_label      = "fgtspoke1"
}

resource "oci_core_virtual_network" "vcn_spoke2" {
  cidr_block     = var.vcn_cidr_spoke2
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-vcn-spoke2"
  dns_label      = "fgtspoke2"
}

resource "oci_core_drg_attachment" "drg_spoke1_attachment" {
  drg_id = oci_core_drg.drg.id
  network_details {
    id = oci_core_virtual_network.vcn_spoke1.id
    type = "VCN"

  }
  display_name = "${var.PREFIX}-drg-spoke1-attachment"
  drg_route_table_id = oci_core_drg_route_table.drg_spoke_route_table.id
}

resource "oci_core_drg_attachment" "drg_spoke2_attachment" {
  drg_id = oci_core_drg.drg.id
  network_details {
    id = oci_core_virtual_network.vcn_spoke2.id
    type = "VCN"

  }
  display_name = "${var.PREFIX}-drg-spoke2-attachment"
  drg_route_table_id = oci_core_drg_route_table.drg_spoke_route_table.id
}

resource "oci_core_drg_route_table" "drg_spoke_route_table" {
  drg_id = oci_core_drg.drg.id
  display_name = "${var.PREFIX}-drg-spoke-route-table"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.drg_spoke_route_distribution.id
}

// Add DRG route distribution for OCI VCN
resource "oci_core_drg_route_distribution" "drg_spoke_route_distribution" {
  // Required
  drg_id = oci_core_drg.drg.id
  distribution_type = "IMPORT"
  // optional
  display_name = "${var.PREFIX}-drg-spoke-route-distribution"
}
resource "oci_core_drg_route_distribution_statement" "drg_spoke_route_distribution_statements" {
  // Required
  drg_route_distribution_id = oci_core_drg_route_distribution.drg_spoke_route_distribution.id
  action = "ACCEPT"
  match_criteria {}
  priority = 1
}


#resource "oci_core_local_peering_gateway" "lpg_hub" {
#  compartment_id = var.compartment_ocid
#  vcn_id         = oci_core_virtual_network.vcn.id
#  display_name   = "${var.PREFIX}-lpg-hub-spoke1"
#}

#resource "oci_core_local_peering_gateway" "lpg_spoke1" {
#  compartment_id = var.compartment_ocid
#  vcn_id         = oci_core_virtual_network.vcn_spoke1.id
#  peer_id        = oci_core_local_peering_gateway.lpg_hub.id
#  display_name   = "${var.PREFIX}-lpg-spoke1-hub"
#}


##############################################################################################################
## DRG
##############################################################################################################

resource "oci_core_drg" "drg" {
  compartment_id = var.compartment_ocid
  display_name = "${var.PREFIX}-drg"
}

resource "oci_core_drg_route_table" "drg_hub_route_table" {
  drg_id = oci_core_drg.drg.id
  display_name = "${var.PREFIX}-drg-hub-route-table"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.drg_hub_route_distribution.id
}

//Create DRG attachment for OCI VCN
resource "oci_core_drg_attachment" "drg_hub_attachment" {
  drg_id = oci_core_drg.drg.id
  network_details {
    id = oci_core_virtual_network.vcn.id
    type = "VCN"

#    route_table_id = oci_core_route_table.drg_routetable.id
#    vcn_route_type = var.drg_attachment_network_details_vcn_route_type
  }
  display_name = "${var.PREFIX}-drg-hub-attachment"
  drg_route_table_id = oci_core_drg_route_table.drg_hub_route_table.id
}

// Add DRG route distribution for OCI VCN
resource "oci_core_drg_route_distribution" "drg_hub_route_distribution" {
  // Required
  drg_id = oci_core_drg.drg.id
  distribution_type = "IMPORT"
  // optional
  display_name = "${var.PREFIX}-drg-hub-route-distribution"
}
resource "oci_core_drg_route_distribution_statement" "drg_hub_route_distribution_statements" {
  // Required
  drg_route_distribution_id = oci_core_drg_route_distribution.drg_hub_route_distribution.id
  action = "ACCEPT"
  match_criteria {}
  priority = 1
}

##############################################################################################################
// route table
resource "oci_core_route_table" "trusted_routetable" {
  depends_on     = [oci_core_vnic_attachment.vnic_attach_trusted_fgt_a]
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "fgt-trusted-routetable"


  //Route to fortigate
  route_rules {
    description       = "Default Route to FGT int"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.nlb_trusted_private_ip.private_ips[0].id
  }
}

resource "oci_core_route_table" "drg_routetable" {
  depends_on     = [oci_core_vnic_attachment.vnic_attach_trusted_fgt_a]
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "fgt-drg-routetable"


  //Route to fortigate
  route_rules {
    description       = "Default Route to FGT int"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.nlb_trusted_private_ip.private_ips[0].id
  }
}

##############################################################################################################
## FortiGate A
##############################################################################################################
// trust nic attachment
resource "oci_core_vnic_attachment" "vnic_attach_trusted_fgt_a" {
  instance_id  = oci_core_instance.vm_fgt_a.id
  display_name = "${var.PREFIX}-fgta-vnic-trusted"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trusted_subnet.id
    display_name           = "${var.PREFIX}-fgta-vnic-trusted"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fgt_ipaddress_a["3"]
  }
}

// create oci instance for active
resource "oci_core_instance" "vm_fgt_a" {
  depends_on = [oci_core_internet_gateway.igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fgta"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = "16"
    ocpus         = "4"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fgta-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fgta-vnic-untrusted"
    private_ip       = var.fgt_ipaddress_a["2"]
  }

  launch_options {
    //    network_type = "PARAVIRTUALIZED"
    network_type = "VFIO"
  }

  source_details {
    source_type = "image"
    source_id   = local.mp_listing_resource_id // marketplace listing
    //source_id = "ocid1.image.oc1.phx.aaaaaaaalvrzh6j2edqh6s42rabhbhclwgnk4owdpjhqu5qsgtur7pc4lqaa"     // private image
    boot_volume_size_in_gbs = "50"
  }

  // Required for bootstrap
  // Commnet out the following if you use the feature.
  metadata = {
    user_data           = base64encode(data.template_file.custom_data_fgt_a.rendered)
#    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "volume_fgt_a" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fgta-volume"
  size_in_gbs         = var.volume_size
}

// Use paravirtualized attachment for now.
resource "oci_core_volume_attachment" "volume_attach_fgt_a" {
  attachment_type = "paravirtualized"
  //attachment_type = "iscsi"   //  user needs to manually add the iscsi disk on fos after
  instance_id = oci_core_instance.vm_fgt_a.id
  volume_id   = oci_core_volume.volume_fgt_a.id
}

// Use for bootstrapping cloud-init
data "template_file" "custom_data_fgt_a" {
  template = file("${path.module}/customdata.tpl")

  vars = {
    fgt_vm_name          = "${var.PREFIX}-fgta"
    fgt_license_file     = "${var.fgt_byol_license_a == "" ? var.fgt_byol_license_a : (fileexists(var.fgt_byol_license_a) ? file(var.fgt_byol_license_a) : var.fgt_byol_license_a)}"
    fgt_license_flexvm   = var.fgt_byol_flexvm_license_a
    port1_ip             = var.fgt_ipaddress_a["2"]
    port1_mask           = var.subnetmask["2"]
    port2_ip             = var.fgt_ipaddress_a["3"]
    port2_mask           = var.subnetmask["3"]
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    trusted_gateway_ip   = oci_core_subnet.trusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    spoke1_cidr          = var.vcn_cidr_spoke1
    spoke2_cidr          = var.vcn_cidr_spoke2
  }
}

##############################################################################################################
## FortiGate B
##############################################################################################################
resource "oci_core_instance" "vm_fgt_b" {
  depends_on = [oci_core_internet_gateway.igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain2 - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fgtb"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = "16"
    ocpus         = "4"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fgtb-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fgtb-vnic-untrusted"
    private_ip       = var.fgt_ipaddress_b["2"]
  }

  launch_options {
    network_type = "VFIO"
  }

  source_details {
    source_type = "image"
    source_id   = local.mp_listing_resource_id // marketplace listing
    //source_id = "ocid1.image.oc1.phx.aaaaaaaalvrzh6j2edqh6s42rabhbhclwgnk4owdpjhqu5qsgtur7pc4lqaa"     // private image
    boot_volume_size_in_gbs = "50"
  }

  // Required for bootstrap
  // Commnet out the following if you use the feature.
  metadata = {
    user_data           = "${base64encode(data.template_file.custom_data_fgt_b.rendered)}"
#    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  timeouts {
    create = "60m"
  }
}

// trusted nic attachment
resource "oci_core_vnic_attachment" "vnic_attach_trusted_fgt_b" {
  instance_id  = oci_core_instance.vm_fgt_b.id
  display_name = "${var.PREFIX}-fgtb-vnic-trusted"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trusted_subnet.id
    display_name           = "${var.PREFIX}-fgtb-vnic-trusted"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fgt_ipaddress_b["3"]
  }
}

resource "oci_core_volume" "volume_fgt_b" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain2 - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fgtb-volume"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "volume_attach_fgt_b" {
  attachment_type = "paravirtualized"
  //attachment_type = "iscsi"   //  user needs to manually add the iscsi disk on fos after
  instance_id = oci_core_instance.vm_fgt_b.id
  volume_id   = oci_core_volume.volume_fgt_b.id
}

// Use for bootstrapping cloud-init
data "template_file" "custom_data_fgt_b" {
  template = file("${path.module}/customdata.tpl")

  vars = {
    fgt_vm_name          = "${var.PREFIX}-fgtb"
    fgt_license_file     = "${var.fgt_byol_license_b == "" ? var.fgt_byol_license_b : (fileexists(var.fgt_byol_license_b) ? file(var.fgt_byol_license_b) : var.fgt_byol_license_b)}"
    fgt_license_flexvm   = var.fgt_byol_flexvm_license_b
    port1_ip             = var.fgt_ipaddress_b["2"]
    port1_mask           = var.subnetmask["2"]
    port2_ip             = var.fgt_ipaddress_b["3"]
    port2_mask           = var.subnetmask["3"]
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    trusted_gateway_ip   = oci_core_subnet.trusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    spoke1_cidr          = var.vcn_cidr_spoke1
    spoke2_cidr          = var.vcn_cidr_spoke2
  }
}

##############################################################################################################
## External Network Load Balancer
##############################################################################################################
resource "oci_network_load_balancer_network_load_balancer" "nlb_untrusted" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-nlb-untrusted"
  subnet_id      = oci_core_subnet.nlb_subnet.id

  is_private                     = false
  is_preserve_source_destination = true
}

resource "oci_network_load_balancer_listener" "nlb_untrusted_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_untrusted_backend_set.name
  name                     = "${var.PREFIX}-nlb-untrusted-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_untrusted.id
  port                     = 0
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend_set" "nlb_untrusted_backend_set" {
  health_checker {
    protocol = "TCP"
    port     = 8008
  }

  name                     = "${var.PREFIX}-untrusted-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_untrusted.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true
}

resource "oci_network_load_balancer_backend" "nlb_untrusted_backend_fgta" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_untrusted_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_untrusted.id
  port                     = 0

  target_id = oci_core_instance.vm_fgt_a.id
}

resource "oci_network_load_balancer_backend" "nlb_untrusted_backend_fgtb" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_untrusted_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_untrusted.id
  port                     = 0

  target_id = oci_core_instance.vm_fgt_b.id
}

##############################################################################################################
## Internal Network Load Balancer
##############################################################################################################
resource "oci_network_load_balancer_network_load_balancer" "nlb_trusted" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-nlb-trusted"
  subnet_id      = oci_core_subnet.trusted_subnet.id

  is_private                     = true
  is_preserve_source_destination = true
}

resource "oci_network_load_balancer_listener" "nlb_trusted_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_trusted_backend_set.name
  name                     = "${var.PREFIX}-nlb-trusted-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_trusted.id
  port                     = 0
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend_set" "nlb_trusted_backend_set" {
  health_checker {
    protocol = "TCP"
    port     = 8008
  }

  name                     = "${var.PREFIX}-trusted-backend-set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_trusted.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true
}

resource "oci_network_load_balancer_backend" "nlb_trusted_backend_fgta" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_trusted_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_trusted.id
  port                     = 0

  target_id = oci_core_instance.vm_fgt_a.id
}

resource "oci_network_load_balancer_backend" "nlb_trusted_backend_fgtb" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_trusted_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_trusted.id
  port                     = 0

  target_id = oci_core_instance.vm_fgt_b.id
}
