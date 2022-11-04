##############################################################################################################
#
# DRGv2 Hub and Spoke traffic inspection
# FortiGate Active/Active Load Balanced pair of standalone FortiGate VMs for resilience and scale
# Terraform deployment template for Oracle Cloud
#
##############################################################################################################

# Gets a list of Availability Domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach_fgt_a" {
  depends_on          = [oci_core_instance.vm_fgt_a]
  availability_domain = oci_core_instance.vm_fgt_a.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_fgt_a.id
}

# Gets the boot volume attachments for each instance
data "oci_core_boot_volume_attachments" "block_attach_fgt_b" {
  depends_on          = [oci_core_instance.vm_fgt_b]
  availability_domain = oci_core_instance.vm_fgt_b.availability_domain
  compartment_id      = var.compartment_ocid
  instance_id         = oci_core_instance.vm_fgt_b.id
}

data "oci_core_private_ips" "fw_private_ip" {
  vnic_id   = element(oci_core_vnic_attachment.vnic_attach_trusted_fgt_a.*.vnic_id, 0)
  subnet_id = oci_core_subnet.trusted_subnet.id
}

data "oci_core_private_ips" "nlb_trusted_private_ip" {
    ip_address = oci_network_load_balancer_network_load_balancer.nlb_trusted.ip_addresses[0].ip_address
    subnet_id = oci_core_subnet.trusted_subnet.id
}

data "oci_network_load_balancer_network_load_balancer" "nlb_trusted" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb_trusted.id
}

output "test" {
  value = data.oci_core_private_ips.nlb_trusted_private_ip.private_ips[0].id
}
