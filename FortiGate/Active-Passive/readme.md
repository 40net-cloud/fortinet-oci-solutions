# FortiGate Active-Passive HA Deployment on Oracle Cloud Infrastructure

Deploy a two-node FortiGate FGCP active-passive cluster on Oracle Cloud Infrastructure (OCI) using Terraform or OCI Resource Manager.

> [!IMPORTANT]
> Review and correct the items in [Known limitations](#known-limitations) before using this template in production. The default network configuration is intentionally permissive and is not production-ready.

## Architecture

The template deploys:

- Two FortiGate instances in active-passive FGCP mode
- Optional placement across different availability and fault domains
- Four VNICs per FortiGate
- Floating trust and untrust private IP addresses
- A reserved public IP mapped to the floating untrust IP
- A block volume for FortiGate logs and data
- Either a new VCN or existing OCI network resources

| Interface | Purpose | Public access |
|---|---|---|
| `port1` | Management | Public IP assigned by default |
| `port2` | Untrust/WAN | Node and floating public IPs |
| `port3` | Trust/LAN | Private only |
| `port4` | FGCP heartbeat | Private only |

During failover, the FortiGate OCI SDN connector reassigns the floating private IPs to the new active instance.

## Prerequisites

Before deployment, confirm that you have:

- An OCI tenancy and compartment
- Permission to create compute, networking, public IP, and block-volume resources
- Sufficient service limits for two FortiGate instances
- Four suitable subnets: management, untrust, trust, and HA heartbeat
- Regional subnets when deploying the nodes across availability domains
- A supported OCI compute shape with at least four VNICs
- Two valid FortiGate licenses for a BYOL deployment, or two PAYG instances
- A FortiFlex token for each node when using FortiFlex licensing
- An OCI dynamic group and IAM policy for the FortiGate HA connector

See:

- [FortiGate OCI HA prerequisites](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/509525)
- [FortiGate OCI instance type support](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/456256)
- [FortiGate OCI licensing options](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/773155/order-types)

## OCI IAM configuration

The FortiGate instances need permission to discover their OCI resources and move the floating private IPs during failover.

Create a dynamic group that includes both FortiGate instances, then add policies equivalent to:

```text
Allow dynamic-group <fortigate-ha-dynamic-group> to read compartments in tenancy
Allow dynamic-group <fortigate-ha-dynamic-group> to read instances in compartment <compartment-name>
Allow dynamic-group <fortigate-ha-dynamic-group> to read vnic-attachments in compartment <compartment-name>
Allow dynamic-group <fortigate-ha-dynamic-group> to read subnets in compartment <compartment-name>
Allow dynamic-group <fortigate-ha-dynamic-group> to manage private-ips in compartment <compartment-name>
```

Adjust the scope and policy statements to meet your organization’s least-privilege requirements. The Terraform template does not create the dynamic group or IAM policies.

## Deployment

### OCI Resource Manager

Click the following button to open the stack in OCI Resource Manager:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FortiGate_Active-Passive_Terraform.zip)

Before applying the stack:

1. Review the Terraform plan.
2. Confirm the FortiGate image and license type.
3. Verify the availability domain and fault domain selections.
4. Confirm that all fixed IP addresses belong to the selected subnets.
5. Confirm that the floating IPs are unused.
6. Replace the default security-list rules.
7. Confirm that the required OCI IAM configuration exists.

### Terraform CLI

Clone the repository:

```bash
git clone https://github.com/40net-cloud/fortinet-oci-solutions.git
cd fortinet-oci-solutions/FortiGate/Active-Passive
```

Create a `terraform.tfvars` file using the variables defined in `variables.tf`.

Do not commit tenancy OCIDs, private keys, FortiFlex tokens, passwords, Terraform state, or plan files to source control.

Initialize and validate:

```bash
terraform init
terraform fmt -check
terraform validate
```

Review and apply the plan:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

For team or production deployments, store Terraform state in a secured remote backend with encryption, access controls, locking, and versioning.

## Post-deployment

### Access FortiGate

Connect to each node using its management public IP:

```text
https://<management-public-ip>
```

The initial username is:

```text
admin
```

Depending on the FortiGate image, the initial password may be the instance OCID. See [Accessing the FortiGate VM](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/721704/accessing-the-fortigate-vm).

Immediately:

- Change the administrator password
- Configure trusted hosts
- Enable multifactor authentication
- Restrict management access to approved source networks
- Remove HTTP access
- Use a bastion host, VPN, or private management network where possible

### Verify HA

From the FortiGate CLI, verify the cluster:

```text
get system ha status
```

Confirm that:

- One node is primary and the other is secondary
- Both nodes are synchronized
- Heartbeat communication uses `port4`
- The expected floating trust and untrust IPs belong to the active node
- The OCI SDN connector is authenticated and operational
- A controlled failover moves the floating IPs to the new active node
- Protected workloads retain the expected connectivity

Test failover during an approved maintenance window.

## Routing

The deployment does not automatically make application subnets use FortiGate.

Create or update workload route tables so protected traffic uses the floating trust private IP as its next hop. Verify that return traffic follows the same path to avoid asymmetric routing.

Also verify that source/destination checking is disabled on every VNIC that forwards traffic. OCI requires this for firewall, NAT, and routing appliances. See [Using a VNIC as a network virtual appliance](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingvnics_tasks-attach.htm).

## Security recommendations

Before production use:

- Replace the allow-all security list with least-privilege ingress and egress rules
- Restrict HTTPS and SSH to trusted management CIDRs
- Do not expose heartbeat or trust interfaces to the internet
- Remove unneeded public IPs from node-specific untrust interfaces
- Prefer private management through OCI Bastion or VPN
- Use NSGs and attach them explicitly to the required VNICs
- Enable logging, monitoring, backups, and administrative MFA
- Review FortiGate incoming port requirements before opening services
- Protect Terraform state because it can contain sensitive values

See [OCI secure network access best practices](https://docs.oracle.com/en/solutions/oci-best-practices/ensure-secure-network-access1.html).

## Known limitations

Review these issues before deployment:

1. **Allow-all security rules**

   The template creates unrestricted ingress and egress security-list rules and applies them to all FortiGate subnets.

2. **Unused NSG**

   An NSG is created but is not attached to the FortiGate VNICs.

3. **Source/destination checking**

   The untrust VNIC configuration should be reviewed. A VNIC forwarding or NATing traffic normally requires source/destination checking to be disabled.

4. **Missing workload routes**

   The template does not create protected-subnet routes targeting the floating trust private IP.

5. **Existing subnet changes**

   Existing-network mode may replace route-table associations on the supplied subnets. Review the Terraform plan carefully.

6. **Subnet masks**

   The bootstrap templates use `255.255.255.0`. Use `/24` subnets unless the bootstrap logic is updated to derive masks from the configured CIDRs.

7. **Jumbo frames**

   The bootstrap configuration sets an MTU of 9000. Confirm jumbo-frame support across the complete traffic path or use a compatible MTU.

8. **Primary bootstrap syntax**

   The primary bootstrap template contains an apparent extra `next`/`end` sequence before the `port4` configuration. Correct and test the generated FortiOS configuration before production deployment.

9. **Shape name**

   Verify the `VM.Standard3.Flex` value. OCI documentation uses `VM.Standard.3.Flex`.

10. **Block-volume attachment**

    Confirm that the selected FortiOS release supports the configured attachment type and recognizes the data disk.

11. **Terraform outputs**

    Useful outputs are currently commented out, while the Resource Manager schema references several output names. Add outputs for management URLs, instance IDs, node IPs, floating IPs, and the cluster public IP.

## Destroying the deployment

Preview destruction first:

```bash
terraform plan -destroy
```

Then destroy only after confirming that no shared or production resources are included:

```bash
terraform destroy
```

Existing-network mode can manage route-table attachments on user-supplied subnets. Review the destroy plan carefully to avoid disrupting other workloads.

## Support

This repository provides deployment automation and is not a substitute for an architecture, security, licensing, or support review.

- [Fortinet OCI documentation](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide)
- [Fortinet Support](https://support.fortinet.com/)
- [OCI documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Repository issues](https://github.com/40net-cloud/fortinet-oci-solutions/issues)