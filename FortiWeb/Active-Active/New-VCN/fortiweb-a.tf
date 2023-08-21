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

  create_vnic_details {
    subnet_id        = oci_core_subnet.untrusted_subnet.id
    display_name     = "${var.PREFIX}-fwba-vnic-untrusted"
    assign_public_ip = true
    hostname_label   = "${var.PREFIX}-fwba-vnic-untrusted"
    private_ip       = var.fwba_ipaddress_port1
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

# FortiWeb-A trust vNIC configuration

resource "oci_core_vnic_attachment" "vnic_attach_trust_a" {
  depends_on = [oci_core_instance.vm_fwb_a]
  instance_id  = oci_core_instance.vm_fwb_a.id
  display_name = "${var.PREFIX}-vnic_trust"

  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id
    display_name           = "${var.PREFIX}-fwba-vnic-trusted"
    assign_public_ip       = false
    skip_source_dest_check = true
    private_ip             = var.fwba_ipaddress_port2
  }
}

### DISK MANAGEMENT ###

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
    fwba_vm_name          = "${var.PREFIX}-fwba"
    untrusted_gateway_ip = oci_core_subnet.untrusted_subnet.virtual_router_ip
    vcn_cidr             = var.vcn
    fwba_ipaddress_port1 = var.fwba_ipaddress_port1
    fwba_ipaddress_port2 = var.fwba_ipaddress_port2
    fwbb_ipaddress_port1 = var.fwbb_ipaddress_port1
    fwbb_ipaddress_port2 = var.fwbb_ipaddress_port2
    trust_mask           = "255.255.255.240"
    untrust_mask         = "255.255.255.240"
  }
}