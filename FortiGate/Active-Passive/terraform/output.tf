# # ------ Print Firewall A (first) in HA Managment Public IP
# output "firewallA_instance_public_ips" {
#   value = [oci_core_instance.fortigate-vms[0].*.public_ip]
# }

# # ------ Print Firewall A (first) in HA Managment Private IP
# output "firewallA_instance_private_ips" {
#   value = [oci_core_instance.fortigate-vms[0].*.private_ip]
# }

# # ------ Print Firewall B (Second) in HA Managment Public IP
# output "firewallB_instance_public_ips" {
#   value = [oci_core_instance.fortigate-vms[1].*.public_ip]
# }

# # ------ Print Firewall B (Second) in HA Managment Private IP
# output "firewallB_instance_private_ips" {
#   value = [oci_core_instance.fortigate-vms[1].*.private_ip]
# }

# # ------ Print Firewall Instances Web URLs
# output "instance_https_urls" {
#   value = formatlist("https://%s", oci_core_instance.fortigate-vms.*.public_ip)
# }

# # ------ Print Initial Instructions
# output "initial_instruction" {
# value = <<EOT
# 1.  In a web browser, 
#     - Connect to the FortiGate Firewall GUI Firewall-1: https://${oci_core_instance.fortigate-vms.0.public_ip}
#     - Connect to the FortiGate Firewall GUI Firewall-2: https://${oci_core_instance.fortigate-vms.1.public_ip}
# 2.  For additional details follow the official documentation.
# EOT
# }