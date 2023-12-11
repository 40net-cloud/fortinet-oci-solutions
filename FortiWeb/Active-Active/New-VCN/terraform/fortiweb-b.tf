##############################################################################################################
## FortiWeb-B 
##############################################################################################################
resource "oci_core_instance" "vm_fwb_b" {
  depends_on = [oci_core_internet_gateway.igw]

  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain2 - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "${var.PREFIX}-fwbb"
  shape               = var.instance_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fwbb-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fwbb-vnic-untrusted"
    private_ip       = var.fwbb_ipaddress_port1
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
    user_data = "${base64encode(data.template_file.custom_data_fwb_b.rendered)}"
    #    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  timeouts {
    create = "60m"
  }
}

# FortiWeb-B trust vNIC configuration

resource "oci_core_vnic_attachment" "vnic_attach_trust_b" {
  depends_on   = [oci_core_instance.vm_fwb_b]
  instance_id  = oci_core_instance.vm_fwb_b.id
  display_name = "${var.PREFIX}-vnic_trust"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id
    display_name           = "${var.PREFIX}-fwbb-vnic-trusted"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fwbb_ipaddress_port2
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
    fwbb_vm_name         = "${var.PREFIX}-fwbb"
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    fwbb_ipaddress_port1 = var.fwbb_ipaddress_port1
    fwbb_ipaddress_port2 = var.fwbb_ipaddress_port2
    fwba_ipaddress_port1 = var.fwba_ipaddress_port1
    fwba_ipaddress_port2 = var.fwba_ipaddress_port2
    trust_mask           = "255.255.255.240"
    untrust_mask         = "255.255.255.240"
  }
}