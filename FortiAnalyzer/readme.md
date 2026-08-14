# FortiAnalyzer Standalone Terraform Deployment for Oracle Cloud

Deploy one standalone FortiAnalyzer-VM on Oracle Cloud Infrastructure (OCI) with Terraform and an OCI Marketplace image.

This template supports deployment through OCI Resource Manager or the Terraform CLI. It is a single-instance, Bring Your Own License (BYOL) deployment; it does not create a FortiAnalyzer HA cluster.

## Contents

- [What this template deploys](#what-this-template-deploys)
- [Supported deployment model](#supported-deployment-model)
- [Prerequisites](#prerequisites)
- [Security requirements](#security-requirements)
- [Deployment with OCI Resource Manager](#deployment-with-oci-resource-manager)
- [Deployment with Terraform CLI](#deployment-with-terraform-cli)
- [Input variables](#input-variables)
- [Outputs](#outputs)
- [Initial access and licensing](#initial-access-and-licensing)
- [Initialize the log disk](#initialize-the-log-disk)
- [Post-deployment hardening](#post-deployment-hardening)
- [Validation and troubleshooting](#validation-and-troubleshooting)
- [Upgrade and lifecycle guidance](#upgrade-and-lifecycle-guidance)
- [Cost considerations](#cost-considerations)
- [Support](#support)

## What this template deploys

The Terraform configuration creates or uses the following resources:

| Resource | Behavior |
| --- | --- |
| FortiAnalyzer-VM | One OCI Compute instance created from a matching FortiAnalyzer Marketplace image |
| License | BYOL Marketplace listing and subscription |
| Management VNIC | One VNIC with a fixed private IP and, currently, an automatically assigned public IP |
| Log storage | One paravirtualized OCI Block Volume attached as an additional disk |
| VCN | Created when `network_strategy` is `Create New VCN and Subnet`; otherwise an existing VCN is used |
| Management subnet | Created with the VCN or supplied by the user for an existing network |
| Internet Gateway and routes | Created for a new VCN; an existing Internet Gateway OCID is required by the current existing-network workflow |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |

## Supported deployment model

FortiAnalyzer-VM for OCI uses the BYOL licensing model. PAYG/On-Demand licensing is not available for FortiAnalyzer on OCI. Obtain and register an appropriate license before the deployment, or confirm that you are eligible for an evaluation license.

The version and image selection is derived from [`terraform/final_listings.json`](terraform/final_listings.json). Available image versions may differ by OCI region and Marketplace availability.

The current template exposes x86 `VM.Standard2.*` shapes. Fortinet also documents supported flexible shapes, but those shapes are not implemented by this Terraform configuration yet. Confirm that the selected shape:

- Is available in the target availability domain.
- Meets the FortiAnalyzer version's minimum CPU and memory requirements.
- Matches the capacity covered by the FortiAnalyzer license.
- Has sufficient performance for the expected logs-per-second, retention period, analytics, and reporting workload.

FortiAnalyzer 7.4 and later require at least 4 vCPUs and 16 GB RAM. In OCI, one OCPU on x86 Compute shapes is equivalent to two vCPUs. See [Fortinet's FortiAnalyzer OCI instance-type guidance](https://docs.fortinet.com/document/fortianalyzer-public-cloud/8.0.0/oci-administration-guide/369910/instance-type-support).

## Prerequisites

Before deploying, prepare the following:

### OCI account and permissions

Use a dedicated OCI compartment for the deployment where practical. The deploying principal needs permission to:

- Read tenancy, compartment, availability-domain, and fault-domain information.
- Create and manage Compute instances and VNICs.
- Create, attach, and manage Block Volumes.
- Create and manage VCN resources when using the new-VCN option.
- Read and subscribe to OCI Marketplace listings.
- Create and run OCI Resource Manager stacks when using the deployment button.

Apply least-privilege IAM policies appropriate to your tenancy structure. Do not grant tenancy-wide `manage all-resources` solely for this deployment.

### Fortinet license

- Obtain a FortiAnalyzer-VM BYOL license or eligible evaluation entitlement.
- Confirm that the license supports the selected CPU capacity and intended workload.
- Have access to the Fortinet Support/FortiCare account used to register and download the license.
- Allow the required outbound connectivity to Fortinet licensing services, or prepare the documented offline entitlement process.

See [Fortinet licensing for FortiAnalyzer on OCI](https://docs.fortinet.com/document/fortianalyzer-public-cloud/8.0.0/oci-administration-guide/583943/licensing).

### Terraform CLI

For CLI deployment, install:

- Terraform 1.0 or later.
- OCI API signing-key credentials or another authentication method supported by the OCI Terraform provider.
- Git.

Store OCI credentials in `~/.oci/config`, environment variables, or another protected credential mechanism. Never commit private keys, credentials, `terraform.tfvars`, saved Terraform plans, or state files.

### Network planning

Choose non-overlapping CIDR ranges and decide how administrators and managed devices will reach FortiAnalyzer.

For an existing network, verify that:

- The management private IP belongs to the selected subnet and is unused.
- Required routes exist to administrator and managed-device networks.
- DNS, NTP, FortiGuard, FortiCare, and other required destinations are reachable.
- Security rules allow only required traffic.
- Changing the subnet's route-table association is acceptable. The current template creates and attaches a route table to the supplied management subnet.

## Security requirements

FortiAnalyzer is a security-sensitive management and logging system. Prefer a private subnet reachable through Site-to-Site VPN, FastConnect, OCI Bastion, or an approved administrative network.

If temporary public management access is unavoidable:

1. Restrict TCP/443 to explicit administrator public CIDRs.
2. Enable TCP/22 only when SSH administration is required and restrict it to the same trusted sources.
3. Never allow all protocols from `0.0.0.0/0`.
4. Restrict log-ingestion ports to known FortiGate, FortiManager, syslog-client, or collector CIDRs.
5. Remove the public IP and Internet Gateway route after private connectivity is established.

Typical inbound traffic may include:

| Purpose | Protocol/port | Recommended source |
| --- | --- | --- |
| HTTPS administration | TCP/443 | Administrator or bastion CIDRs only |
| SSH administration | TCP/22 | Administrator or bastion CIDRs only; disable if unused |
| Fortinet logging/OFTP | TCP/514 | Known managed-device or collector CIDRs |
| Syslog | UDP/514 or TCP/514 | Known syslog-client CIDRs |
| FortiGate management | TCP/541 | Known FortiGate CIDRs when required |

Open only the ports required by the features you use. Consult the [FortiAnalyzer incoming-port reference](https://docs.fortinet.com/document/fortianalyzer/7.4.0/fortianalyzer-ports/290737/incoming-ports) before defining production security rules.

OCI recommends least-privilege NSG and security-list rules, private subnets for sensitive systems, and VCN Flow Logs. See [OCI secure network access recommendations](https://docs.oracle.com/en/solutions/oci-best-practices/ensure-secure-network-access1.html).

## Deployment with OCI Resource Manager

| FortiAnalyzer standalone |
| :---: |
| [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FortiAnalyzer_Standalone_Terraform.zip) |

To deploy:

1. Sign in to the intended OCI tenancy and region.
2. Select **Deploy to Oracle Cloud**.
3. Review the downloaded Terraform configuration before accepting it.
4. Select the compartment in which to create the Resource Manager stack.
5. Choose a supported Terraform version.
6. Configure all required inputs.
7. Set the administrator source CIDR to a specific trusted range after the Terraform security-rule implementation has been corrected. Do not use `0.0.0.0/0`.
8. Create the stack without automatically applying it.
9. Run and review a **Plan** job.
10. Confirm the instance shape, image version, public IP behavior, routes, security rules, and Block Volume size.
11. Run **Apply** only after the plan has been approved.

For OCI Resource Manager configuration requirements, see [Terraform configurations for Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm).

## Deployment with Terraform CLI

### 1. Clone the repository

```shell
git clone https://github.com/40net-cloud/fortinet-oci-solutions.git
cd fortinet-oci-solutions/FortiAnalyzer/terraform
```

### 2. Configure OCI authentication

For example, configure an OCI CLI profile in `~/.oci/config` and protect the associated private key. The provider can also use supported environment-based authentication.

Do not place private-key contents in Terraform source files or commit credential paths intended only for your workstation.

### 3. Create `terraform.tfvars`

The following example illustrates the principal inputs. Replace every example value with values for your tenancy and network.

```hcl
tenancy_ocid             = "ocid1.tenancy.oc1..example"
user_ocid                = "ocid1.user.oc1..example"
fingerprint              = "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"
private_key_path         = "/secure/path/to/oci_api_key.pem"
region                   = "eu-frankfurt-1"
compute_compartment_ocid = "ocid1.compartment.oc1..example"

availability_domain_name_1 = "example-AD-1"
fault_domain_name_1        = "FAULT-DOMAIN-1"

license_type     = "BYOL"
cpu_type         = "X64"
fortios_version  = "8.0.0" # Variable name retained for compatibility; this selects the FortiAnalyzer version.
vm_compute_shape = "VM.Standard2.2"

network_strategy             = "Create New VCN and Subnet"
vcn_display_name             = "FortiAnalyzer-VCN"
vcn_cidr_block               = "10.20.0.0/16"
vcn_dns_label                = "fazvcn"
management_subnet_cidr_block = "10.20.1.0/24"
management_subnet_dns_label  = "management"
mgmt_private_ip_primary_a    = "10.20.1.10"

# Size this log disk according to the FortiAnalyzer license and retention requirements.
volume_size = 200

# SECURITY NOTE: The current Terraform does not enforce this input.
# Do not rely on it until the NSG implementation has been corrected and tested.
nsg_whitelist_ip = "203.0.113.10/32"
```

For an existing VCN, at minimum review and set:

```hcl
network_strategy     = "Use Existing VCN and Subnet"
vcn_id               = "ocid1.vcn.oc1..example"
management_subnet_id = "ocid1.subnet.oc1..example"
igw_ocid             = "ocid1.internetgateway.oc1..example"

# Must be an unused address in management_subnet_id.
mgmt_private_ip_primary_a = "10.20.1.10"
```

The existing-network workflow currently attaches a newly created route table to the selected management subnet. Review this behavior carefully because it can change connectivity for other resources in that subnet.

### 4. Initialize and validate

```shell
terraform init
terraform fmt -check
terraform validate
```

### 5. Create and review a plan

```shell
terraform plan -out=tfplan
terraform show tfplan
```

The saved plan may contain sensitive values. Store it securely and delete it after use. Never publish it in a release archive.

Review at least:

- Selected Marketplace image and FortiAnalyzer version.
- Instance shape, availability domain, and fault domain.
- Whether a public IP will be assigned.
- Every ingress and egress rule.
- Default routes and Internet Gateway usage.
- Management private IP and subnet membership.
- Log-volume size and attachment type.
- Changes to existing VCN resources.

### 6. Apply

```shell
terraform apply tfplan
```

Keep the resulting Terraform state in a secure, access-controlled remote backend for team or production use. The current configuration does not define a remote backend.

## Input variables

The authoritative input definitions are in [`terraform/variables.tf`](terraform/variables.tf). The Resource Manager UI schema is in [`terraform/marketplace.yaml`](terraform/marketplace.yaml).

Important inputs include:

| Variable | Description |
| --- | --- |
| `compute_compartment_ocid` | Compartment for Compute, storage, network, and Marketplace subscription resources |
| `region` | OCI deployment region |
| `availability_domain_name_1` | Availability domain for the instance and Block Volume |
| `fault_domain_name_1` | Fault domain for the instance |
| `license_type` | FortiAnalyzer Marketplace licensing type; use `BYOL` |
| `cpu_type` | Image architecture; the Resource Manager schema currently exposes `X64` |
| `fortios_version` | FortiAnalyzer image version; the variable should be renamed in a future breaking release |
| `vm_compute_shape` | OCI Compute shape |
| `network_strategy` | Create a new VCN/subnet or use existing resources |
| `management_subnet_id` | Existing management subnet when the existing-network strategy is selected |
| `mgmt_private_ip_primary_a` | Fixed private address for the FortiAnalyzer management VNIC |
| `volume_size` | Additional log-volume size in GB |
| `mp_subscription_enabled` | Whether Terraform accepts and creates the Marketplace subscription |

Some variables in the current schema originated from FortiGate HA templates and are not used by this standalone FortiAnalyzer deployment. Do not infer that HA, trust/untrust networking, floating IPs, flexible shapes, or configurable VNIC types are implemented merely because similarly named fields appear in the schema.

## Outputs

After a successful apply, Terraform returns:

| Output | Description |
| --- | --- |
| `fortianalyzer_vm_a_public_ip` | Public IPv4 address assigned to the FortiAnalyzer management VNIC |

Retrieve it with:

```shell
terraform output fortianalyzer_vm_a_public_ip
```

The instance OCID and private IP are not currently exported. Find them on the OCI Compute instance details page. Adding explicit `instance_id`, `private_ip`, and `https_url` outputs is recommended.

## Initial access and licensing

1. Wait for the OCI Compute instance to reach the **Running** state.
2. Copy the instance public or private IP, depending on the approved management path.
3. Copy the instance OCID from the OCI Console.
4. Browse to `https://<management-ip>`.
5. Expect a certificate warning until a trusted certificate is installed.
6. Sign in with username `admin` and use the instance OCID as the initial password.
7. Activate the BYOL or eligible evaluation license. The appliance may reboot.
8. Change the administrator password immediately.
9. Create named administrator accounts and stop using the shared built-in account for routine administration.

FortiAnalyzer must validate its license with FortiGuard registration services within the documented validation window unless the offline entitlement process is used. See [Connecting to FortiAnalyzer-VM on OCI](https://docs.fortinet.com/document/fortianalyzer-public-cloud/8.0.0/oci-administration-guide/859327/connecting-to-the-fortianalyzer-vm).

## Initialize the log disk

The attached Block Volume is intended for FortiAnalyzer logs and analytics data. Disk size must be based on the license, ingestion rate, retention target, and reporting workload.

After deployment:

1. Confirm that the additional OCI Block Volume is attached read/write.
2. Gracefully reboot or stop/start the FortiAnalyzer instance so it discovers the disk.
3. Sign in to the FortiAnalyzer CLI.
4. Check LVM status:

   ```text
   execute lvm info
   ```

5. If the disk is shown as unused, start LVM disk management:

   ```text
   execute lvm start
   ```

6. Confirm the prompt. FortiAnalyzer reboots.
7. Run `execute lvm info` again and confirm that the disk is used.
8. For later disks, follow the Fortinet procedure for `execute lvm extend`.

Back up logs and perform a graceful shutdown before resizing storage. Follow [Fortinet's OCI log-disk procedure](https://docs.fortinet.com/document/fortianalyzer-public-cloud/7.6.0/oci-administration-guide/31403/adding-a-disk-to-the-fortianalyzer-vm-for-logging).

## Post-deployment hardening

Complete the following before onboarding production devices:

- Replace the default certificate with a certificate trusted by administrators and API clients.
- Change the built-in administrator password and create named accounts.
- Enable MFA or enterprise authentication where supported.
- Configure administrator trusted hosts.
- Disable HTTP and unused administrative protocols.
- Restrict OCI security rules and FortiAnalyzer trusted hosts to approved source networks.
- Remove the public IP after private management connectivity is working.
- Configure trusted DNS and NTP sources.
- Configure backups and test restoration.
- Enable OCI VCN Flow Logs and appropriate monitoring.
- Configure alarms for instance health, Block Volume utilization, and relevant service limits.
- Configure FortiAnalyzer disk-usage thresholds and retention policies.
- Onboard managed devices gradually and verify log receipt, ADOM assignment, retention, and report performance.
- Record the deployed image, license, shape, disk sizing, network flows, and recovery procedure.

## Validation and troubleshooting

### No instance was created

The instance resource is conditional on finding exactly one Marketplace package that matches `license_type`, `cpu_type`, and `fortios_version`. Verify that:

- The selected version exists in `final_listings.json`.
- The image is available in the selected region.
- `license_type` is `BYOL`.
- `cpu_type` matches the selected image.
- Marketplace terms can be accepted in the target compartment.

### The management private IP is rejected

Confirm that `mgmt_private_ip_primary_a`:

- Belongs to the selected management subnet CIDR.
- Is not the subnet gateway, broadcast address, or another reserved address.
- Is not already assigned to another VNIC.

### The GUI is unreachable

Check:

- VNIC public/private IP assignment.
- Subnet route-table association.
- Internet Gateway, VPN, FastConnect, peering, or Bastion reachability.
- Security lists and NSGs.
- TCP/443 administrative access on FortiAnalyzer.
- FortiAnalyzer static routes.
- Whether the appliance is rebooting after license or LVM activation.

### The log disk is not visible

Confirm that the Block Volume is attached in the same availability domain and reboot the instance. Then check `execute lvm info` and follow the [Fortinet disk initialization procedure](https://docs.fortinet.com/document/fortianalyzer-public-cloud/7.6.0/oci-administration-guide/31403/adding-a-disk-to-the-fortianalyzer-vm-for-logging).

### Resource Manager does not detect Terraform

Inspect the release ZIP. The selected Resource Manager working directory must contain the `.tf` files, and `marketplace.yaml` should accompany the configuration. For the deployment button, package these files at the archive root.

## Upgrade and lifecycle guidance

- Read the FortiAnalyzer release notes and upgrade path before changing versions.
- Back up configuration and logs before upgrades, shape changes, or disk changes.
- Do not change `fortios_version` in place without confirming whether the OCI Marketplace image and Terraform replacement behavior support the intended upgrade.
- Test upgrades in a non-production environment.
- Review Marketplace image availability before deleting or replacing an existing instance.
- Use FortiAnalyzer-supported backup and migration procedures rather than relying solely on Terraform state.

To remove resources managed by the CLI deployment:

```shell
terraform plan -destroy
terraform destroy
```

Review the destroy plan carefully. Confirm backup and retention requirements before destroying the instance or its log volume. Marketplace subscriptions, external network resources, backups, and snapshots may require separate handling.

## Cost considerations

This deployment can incur charges for:

- OCI Compute OCPUs and memory.
- Boot and Block Volume capacity, performance, backups, and snapshots.
- Public IPv4 addresses where applicable.
- Network egress and cross-region traffic.
- OCI monitoring and logging retention.
- FortiAnalyzer licensing and support.

Configure OCI budgets and cost alerts before production deployment. Monitor disk growth because log retention, reports, analytics, temporary files, backups, and snapshots can increase storage consumption. Fortinet summarizes these responsibilities in its [FortiAnalyzer for OCI guide](https://docs.fortinet.com/document/fortianalyzer-public-cloud/8.0.0/oci-administration-guide).

## Repository files

| File | Purpose |
| --- | --- |
| [`terraform/provider.tf`](terraform/provider.tf) | Terraform and OCI provider requirements |
| [`terraform/variables.tf`](terraform/variables.tf) | Terraform input variables and validations |
| [`terraform/locals.tf`](terraform/locals.tf) | Image-selection and deployment logic |
| [`terraform/compute.tf`](terraform/compute.tf) | FortiAnalyzer instance, log volume, and attachment |
| [`terraform/network.tf`](terraform/network.tf) | VCN, subnet, gateways, routes, security list, and NSG |
| [`terraform/data_sources.tf`](terraform/data_sources.tf) | OCI identity and network lookups |
| [`terraform/image_subscription.tf`](terraform/image_subscription.tf) | Marketplace agreement and subscription |
| [`terraform/output.tf`](terraform/output.tf) | Terraform outputs |
| [`terraform/marketplace.yaml`](terraform/marketplace.yaml) | OCI Resource Manager UI schema |
| [`terraform/final_listings.json`](terraform/final_listings.json) | Generated Marketplace listing and image metadata |

## Support

For template defects or documentation corrections, [open a GitHub issue](https://github.com/40net-cloud/fortinet-oci-solutions/issues) and include:

- Deployment method: Resource Manager or Terraform CLI.
- OCI region and availability domain.
- Terraform and OCI provider versions.
- Selected FortiAnalyzer version and Compute shape.
- New or existing VCN selection.
- Sanitized `terraform plan` or Resource Manager job error.

Do not include private keys, passwords, license files, Terraform state, saved plans, full OCIDs, public IP addresses, or other sensitive tenancy information.

For FortiAnalyzer product, licensing, or operational support, use the applicable Fortinet support channel and consult the [FortiAnalyzer Public Cloud documentation](https://docs.fortinet.com/document/fortianalyzer-public-cloud/8.0.0/oci-administration-guide).