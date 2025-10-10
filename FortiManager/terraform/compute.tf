######################################
####### Create FortiManager VM #######
######################################

resource "oci_core_instance" "vm-a" {
  count = local.matched_package != null ? 1 : 0
  availability_domain = ( var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : ( length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "FortiManager-Standalone-VM"
  shape               = local.vm_compute_shape

  create_vnic_details {
    subnet_id        = local.use_existing_network ? var.management_subnet_id : oci_core_subnet.management_subnet[0].id
    display_name     = "vm-a"
    assign_public_ip = true
    hostname_label   = "vma"
    private_ip       = var.mgmt_private_ip_primary_a
  }

  source_details {
    source_type = "image"
    source_id   = local.matched_package.image_id
  }
  
  timeouts {
    create = "60m"
  }
}

resource "oci_core_volume" "vm_volume-a" {
  count = 1
  availability_domain = ( var.availability_domain_name_1 != "" ? var.availability_domain_name_1 : ( length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-a" {
  count = length(oci_core_instance.vm-a) > 0 ? 1 : 0
  attachment_type = "paravirtualized"
  instance_id = oci_core_instance.vm-a[0].id
  volume_id       = oci_core_volume.vm_volume-a[count.index].id
}