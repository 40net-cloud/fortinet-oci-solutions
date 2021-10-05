resource "oci_core_volume" "vm_volume-a" {
  availability_domain = data.oci_identity_availability_domain.ad-a.name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-a"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-a" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm-a.id
  volume_id       = oci_core_volume.vm_volume-a.id
}


resource "oci_core_volume" "vm_volume-b" {
  availability_domain = data.oci_identity_availability_domain.ad-b.name
  compartment_id      = var.compartment_ocid
  display_name        = "vm_volume-b"
  size_in_gbs         = var.volume_size
}

resource "oci_core_volume_attachment" "vm_volume_attach-b" {
  attachment_type = "paravirtualized"
  instance_id     = oci_core_instance.vm-b.id
  volume_id       = oci_core_volume.vm_volume-b.id
}
