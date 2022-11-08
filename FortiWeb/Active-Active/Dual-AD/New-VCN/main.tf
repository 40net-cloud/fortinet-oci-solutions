##############################################################################################################
#
# DRGv2 Hub and Spoke ingress traffic inspection
# FortiWeb Active/Active Load Balanced pair of standalone FortiWeb VMs for resilience and scale using config sync
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

##############################################################################################################
## 1. NETWORK COMPONENTS
##############################################################################################################

##############################################################################################################
## 1.1 HUB VCN settings
##############################################################################################################

# Hub VCN name & CIDR
resource "oci_core_virtual_network" "vcn" {
  cidr_block     = var.vcn
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-vcn"
  dns_label      = "fwbhub"
}

# Internet Gateway for Hub VCN
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-igw"
  vcn_id         = oci_core_virtual_network.vcn.id
}

##############################################################################################################
## 1.2 SPOKE1 VCN
##############################################################################################################

# Spoke1 VCN name & CIDR
resource "oci_core_virtual_network" "vcn_spoke1" {
  cidr_block     = var.vcn_cidr_spoke1
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-vcn-spoke1"
  dns_label      = "fwbspoke1"
}
# Internet Gateway for Spoke1 VCN
resource "oci_core_internet_gateway" "spoke1_igw" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-spoke1_igw"
  vcn_id         = oci_core_virtual_network.vcn_spoke1.id
}

##############################################################################################################
## 1.2 LOAD BALANCER SUBNET (created in Hub VCN)
##############################################################################################################

# Load Balancer subnet settings
resource "oci_core_subnet" "lb_subnet" {
  cidr_block        = var.subnet["1"]
  display_name      = "${var.PREFIX}-lb"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn.id
  route_table_id    = oci_core_route_table.lb_routetable.id
  security_list_ids = ["${oci_core_virtual_network.vcn.default_security_list_id}", "${oci_core_security_list.untrusted_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  dns_label         = "fwbloadbalancer"
}

# Route Table for load balancer subnet
resource "oci_core_route_table" "lb_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-lb-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

##############################################################################################################
## SPOKE1 SUBNET
##############################################################################################################

# Spoke1 subnet settings
resource "oci_core_subnet" "spoke1_subnet" {
  cidr_block        = var.subnet["3"]
  display_name      = "${var.PREFIX}-spoke1"
  compartment_id    = var.compartment_ocid
  route_table_id    = oci_core_route_table.spoke1_routetable.id
  vcn_id            = oci_core_virtual_network.vcn_spoke1.id
  dns_label         = "spoke1"
}

# Route Table for Spoke1 subnet
resource "oci_core_route_table" "spoke1_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn_spoke1.id
  display_name   = "${var.PREFIX}-spoke1-rt"

  route_rules {
    destination       = var.vcn
    network_entity_id = oci_core_drg.drg.id
  }
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.spoke1_igw.id
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
  vcn_id            = oci_core_virtual_network.vcn.id
  route_table_id    = oci_core_route_table.untrusted_routetable.id
  security_list_ids = ["${oci_core_virtual_network.vcn.default_security_list_id}", "${oci_core_security_list.untrusted_security_list.id}"]
  dhcp_options_id   = oci_core_virtual_network.vcn.default_dhcp_options_id
  dns_label         = "fwbuntrusted"
}

# Route table for Untrusted subnet

resource "oci_core_route_table" "untrusted_routetable" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-untrusted-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id

  }
  route_rules {
 
    destination       = var.vcn_cidr_spoke1
    network_entity_id = oci_core_drg.drg.id
  }
}

# Security List for Untrusted Subnet

resource "oci_core_security_list" "untrusted_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.PREFIX}-untrusted-security-list"

  // allow outbound TCP traffic on all ports
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  // allow inbound HTTP (port 80) traffic
  ingress_security_rules {
    protocol = "6" // tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 80
      max = 80
    }
  }

  // allow inbound HTTPS (port 443) traffic
  ingress_security_rules {
    protocol = "6" // tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 443
      max = 443
    }
  }

    // allow inbound Management-GUI (port 8443) traffic
  ingress_security_rules {
    protocol = "6" // tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 8443
      max = 8443
    }
  }

  // allow inbound SSH (port 22) traffic
  ingress_security_rules {
    protocol  = "6" // tcp
    source    = "0.0.0.0/0"
    stateless = false

    tcp_options {
      min = 22
      max = 22
    }
  }

  // allow inbound ICMP traffic of a specific type
  ingress_security_rules {
    protocol = 1
    source   = "0.0.0.0/0"
  }
}

##############################################################################################################
## DRG Configuration
##############################################################################################################

# DRG name
resource "oci_core_drg" "drg" {
  compartment_id = var.compartment_ocid
  display_name = "${var.PREFIX}-drg"
}

# DRG route table for Hub VCN
resource "oci_core_drg_route_table" "drg_hub_route_table" {
  drg_id = oci_core_drg.drg.id
  display_name = "${var.PREFIX}-drg-hub-route-table"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.drg_hub_route_distribution.id
}

# DRG attachment for Hub VCN
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

# DRG route distribution for Hub VCN
resource "oci_core_drg_route_distribution" "drg_hub_route_distribution" {
  # Required
  drg_id = oci_core_drg.drg.id
  distribution_type = "IMPORT"
  # Optional
  display_name = "${var.PREFIX}-drg-hub-route-distribution"
}

# DRG route distribution statement for Hub VCN
resource "oci_core_drg_route_distribution_statement" "drg_hub_route_distribution_statements" {
  # Required
  drg_route_distribution_id = oci_core_drg_route_distribution.drg_hub_route_distribution.id
  action = "ACCEPT"
  match_criteria {}
  priority = 1
}

# DRG attachment for Spoke1-VCN
resource "oci_core_drg_attachment" "drg_spoke1_attachment" {
  drg_id = oci_core_drg.drg.id
  network_details {
    id = oci_core_virtual_network.vcn_spoke1.id
    type = "VCN"

  }
  display_name = "${var.PREFIX}-drg-spoke1-attachment"
  drg_route_table_id = oci_core_drg_route_table.drg_spoke_route_table.id
}

# Route table for Spoke1 VCN
resource "oci_core_drg_route_table" "drg_spoke_route_table" {
  drg_id = oci_core_drg.drg.id
  display_name = "${var.PREFIX}-drg-spoke-route-table"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.drg_spoke_route_distribution.id
}

# DRG route distribution for Spoke1 VCN
resource "oci_core_drg_route_distribution" "drg_spoke_route_distribution" {
  // Required
  drg_id = oci_core_drg.drg.id
  distribution_type = "IMPORT"
  // optional
  display_name = "${var.PREFIX}-drg-spoke-route-distribution"
}

# DRG route distribution statement for Spoke1 VCN
resource "oci_core_drg_route_distribution_statement" "drg_spoke_route_distribution_statements" {
  // Required
  drg_route_distribution_id = oci_core_drg_route_distribution.drg_spoke_route_distribution.id
  action = "ACCEPT"
  match_criteria {}
  priority = 1
}

##############################################################################################################
## EXTERNAL LOAD BALANCER Configuration
##############################################################################################################

# Load Balancer name & shape
resource "oci_load_balancer_load_balancer" "lb_external" {
  #Required
  depends_on     = [oci_core_instance.vm_fwb_b]
  compartment_id = var.compartment_ocid
  display_name   = "${var.PREFIX}-lb-untrusted"
  shape          = var.load_balancer_shape
  subnet_ids     = [oci_core_subnet.lb_subnet.id]
  #Optional
  is_private     = false
}

# Load Balancer Listener
resource "oci_load_balancer_listener" "lb_external_listener" {
  default_backend_set_name = oci_load_balancer_backend_set.lb_external_backend_set.name
  name                     = "${var.PREFIX}-lb-untrusted-listener"
  load_balancer_id         = oci_load_balancer_load_balancer.lb_external.id
  port                     = 80
  protocol                 = "HTTP"
}

# Load Balancer Backend Set
resource "oci_load_balancer_backend_set" "lb_external_backend_set" {
  health_checker {
    protocol = "HTTP"
    port     = 80
    url_path = "/"
  }

  name                     = "${var.PREFIX}-untrusted-backend-set"
  load_balancer_id = oci_load_balancer_load_balancer.lb_external.id
  policy                   = "ROUND_ROBIN"
}

# Load Balancer Backends
resource "oci_load_balancer_backend" "lb_external_backend_fwba" {
  backendset_name          = oci_load_balancer_backend_set.lb_external_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.lb_external.id
  port                     = 80
  ip_address               = var.fwb_ipaddress_a
}

resource "oci_load_balancer_backend" "lb_external_backend_fwbb" {
  backendset_name          = oci_load_balancer_backend_set.lb_external_backend_set.name
  load_balancer_id         = oci_load_balancer_load_balancer.lb_external.id
  port                     = 80
  ip_address               = var.fwb_ipaddress_b
}

# Comment out if LPG is required

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
## FortiWeb-A Configuration
##############################################################################################################

# FortiWeb-A instance configuration
resource "oci_core_instance" "vm_fwb_a" {
  depends_on = [oci_core_internet_gateway.igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fwba"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = "16"
    ocpus         = "4"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fwba-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fwba-vnic-untrusted"
    private_ip       = var.fwb_ipaddress_a
  }

  launch_options {
    //    network_type = "PARAVIRTUALIZED"
    network_type = "PARAVIRTUALIZED"
  }

    source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid // marketplace listing
    //source_id = "ocid1.image.oc1.phx.aaaaaaaalvrzh6j2edqh6s42rabhbhclwgnk4owdpjhqu5qsgtur7pc4lqaa"     // private image
    boot_volume_size_in_gbs = "50"
  }  
 
  // Required for bootstrap
  // Commnet out the following if you use the feature.
  metadata = {
    user_data           = base64encode(data.template_file.custom_data_fwb_a.rendered)
#    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "volume_fwb_a" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fwba-volume"
  size_in_gbs         = var.volume_size
}

// Use paravirtualized attachment for now.
resource "oci_core_volume_attachment" "volume_attach_fwb_a" {
  attachment_type = "paravirtualized"
  //attachment_type = "iscsi"   //  user needs to manually add the iscsi disk on fos after
  instance_id = oci_core_instance.vm_fwb_a.id
  volume_id   = oci_core_volume.volume_fwb_a.id
}

// Use for bootstrapping cloud-init
data "template_file" "custom_data_fwb_a" {
  template = file("${path.module}/customdatafwba.tpl")

  vars = {
    fwb_vm_name          = "${var.PREFIX}-fwba"
    fwb_license_file     = "${var.fwb_byol_license_a == "" ? var.fwb_byol_license_a : (fileexists(var.fwb_byol_license_a) ? file(var.fwb_byol_license_a) : var.fwb_byol_license_a)}"
    fwb_license_flexvm   = var.fwb_byol_flexvm_license_a
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    spoke1_cidr          = var.vcn_cidr_spoke1
    fwb_ipaddress_a      = var.fwb_ipaddress_a
  }
}

##############################################################################################################
## FortiWeb-B 
##############################################################################################################
resource "oci_core_instance" "vm_fwb_b" {
  depends_on = [oci_core_internet_gateway.igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain2 - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fwbb"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = "16"
    ocpus         = "4"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fwbb-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fwbb-vnic-untrusted"
    private_ip       = var.fwb_ipaddress_b
  }

  launch_options {
    network_type = "PARAVIRTUALIZED"
  }

    source_details {
    source_type = "image"
    source_id   = var.vm_image_ocid // marketplace listing
    //source_id = "ocid1.image.oc1.phx.aaaaaaaalvrzh6j2edqh6s42rabhbhclwgnk4owdpjhqu5qsgtur7pc4lqaa"     // private image
    boot_volume_size_in_gbs = "50"
  }

  // Required for bootstrap
  // Commnet out the following if you use the feature.
  metadata = {
    user_data           = "${base64encode(data.template_file.custom_data_fwb_b.rendered)}"
#    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "volume_fwb_b" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain2 - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fwbb-volume"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "volume_attach_fwb_b" {
  attachment_type = "paravirtualized"
  //attachment_type = "iscsi"   //  user needs to manually add the iscsi disk on fos after
  instance_id = oci_core_instance.vm_fwb_b.id
  volume_id   = oci_core_volume.volume_fwb_b.id
}

// Use for bootstrapping cloud-init
data "template_file" "custom_data_fwb_b" {
  template = file("${path.module}/customdatafwbb.tpl")

  vars = {
    fwb_vm_name          = "${var.PREFIX}-fwbb"
    fwb_license_file     = "${var.fwb_byol_license_b == "" ? var.fwb_byol_license_b : (fileexists(var.fwb_byol_license_b) ? file(var.fwb_byol_license_b) : var.fwb_byol_license_b)}"
    fwb_license_flexvm   = var.fwb_byol_flexvm_license_b
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    spoke1_cidr          = var.vcn_cidr_spoke1
    fwb_ipaddress_b      = var.fwb_ipaddress_b
  }
}

##############################################################################################################
## Spoke1-VM Configuration
##############################################################################################################

# Spoke1-VM instance configuration
resource "oci_core_instance" "vm_spoke1" {
  depends_on = [oci_core_internet_gateway.spoke1_igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-spoke1vm"
  shape               = var.instance_shape
  shape_config {
    memory_in_gbs = "16"
    ocpus         = "1"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.spoke1_subnet.id
    display_name     = "${var.PREFIX}-spoke1vm-vnic"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-vnic-spoke1"
    private_ip       = var.spoke1vm_ipaddress
  }

  launch_options {
    //    network_type = "PARAVIRTUALIZED"
    network_type = "PARAVIRTUALIZED"
  }

    source_details {
    source_type = "image"
    source_id   = var.spoke1vm_image_ocid // marketplace listing
    boot_volume_size_in_gbs = "50"
  }  
 
  // Required for bootstrap
  // Commnet out the following if you use the feature.
  #metadata = {
   # user_data           = base64encode(data.template_file.custom_data_fwb_a.rendered)
#    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
}