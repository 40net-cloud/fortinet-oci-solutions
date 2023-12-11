resource "oci_core_volume" "vm_volume-a" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_a - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-a" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.FortiGate-A.id
  volume_id       = oci_core_volume.vm_volume-a.id
}


resource "oci_core_volume" "vm_volume-b" {
  availability_domain = lookup(data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain_b - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-b"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-b" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.FortiGate-B.id
  volume_id       = oci_core_volume.vm_volume-b.id
}
