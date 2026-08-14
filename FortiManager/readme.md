# FortiManager Standalone Deployment on Oracle Cloud Infrastructure

Deploy one standalone FortiManager-VM on Oracle Cloud Infrastructure (OCI) using Terraform and an OCI Marketplace image.

This template supports deployment through OCI Resource Manager or the Terraform CLI. It is a single-instance deployment and does not create a FortiManager High Availability cluster.

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
- [Initialize the data disk](#initialize-the-data-disk)
- [FortiManager initial configuration](#fortimanager-initial-configuration)
- [Post-deployment hardening](#post-deployment-hardening)
- [Validation and troubleshooting](#validation-and-troubleshooting)
- [Upgrade and lifecycle guidance](#upgrade-and-lifecycle-guidance)
- [Cost considerations](#cost-considerations)
- [Repository files](#repository-files)
- [Support](#support)

## What this template deploys

The Terraform configuration creates or uses the following resources:

| Resource | Behavior |
| --- | --- |
| FortiManager-VM | One OCI Compute instance created from a matching FortiManager Marketplace image |
| License | BYOL Marketplace listing and subscription |
| Management VNIC | One VNIC with a fixed private IP and, currently, an automatically assigned public IP |
| Data storage | One OCI Block Volume attached as an additional disk |
| VCN | Created when `network_strategy` is `Create New VCN and Subnet`; otherwise, an existing VCN is used |
| Management subnet | Created with the VCN or supplied by the user for an existing network |
| Internet Gateway and routes | Created for a new VCN; an existing Internet Gateway OCID is required by the current existing-network workflow |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |

The deployment does **not** create or configure:

- FortiManager HA or a second FortiManager instance
- A load balancer or floating cluster IP
- FortiManager certificates, authentication servers, backups, or monitoring
- Automatic FortiManager LVM initialization for the attached data disk

## Supported deployment model

The current template exposes the BYOL Marketplace option. Obtain and register an appropriate FortiManager license before deployment or confirm that you are eligible for an evaluation license.

The image selection is derived from [`terraform/final_listings.json`](terraform/final_listings.json). Available versions may differ by OCI region and Marketplace availability.

The current Resource Manager schema offers the following versions:

- FortiManager 8.0.0
- FortiManager 7.6.4
- FortiManager 7.4.11
- FortiManager 7.2.11
- FortiManager 7.0.14
- FortiManager 6.4.15

Treat this list as informational. The authoritative available versions are the matching FortiManager packages in `final_listings.json`.

### Compute sizing

The current Terraform accepts only these x86 previous-generation shapes:

- `VM.Standard2.2`
- `VM.Standard2.4`
- `VM.Standard2.8`
- `VM.Standard2.16`
- `VM.Standard2.24`

Fortinet also supports selected flexible shapes for FortiManager 7.2.0 and later, but flexible-shape OCPU and memory configuration is not implemented by this Terraform template.

FortiManager requires:

- At least 4 vCPUs and 8 GB RAM for older supported releases.
- At least 4 vCPUs and 16 GB RAM for FortiManager 7.2.2 and later.
- A shape and CPU allocation compatible with the FortiManager license.

On x86 OCI Compute shapes, one OCPU is equivalent to two vCPUs.

Select capacity based on:

- Number of managed devices
- Number of VDOMs
- Number and size of ADOMs
- Policy package and object database size
- Concurrent administrators
- Workspace and workflow usage
- Logging and reporting requirements
- Scheduled scripts, backups, and policy installations

See [Fortinet's FortiManager OCI instance-type guidance](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide/369910/instance-type-support).

## Prerequisites

Before deploying, prepare the following.

### OCI account and permissions

Use a dedicated OCI compartment where practical. The deployment principal needs permission to:

- Read tenancy and compartment information.
- Read availability domains and fault domains.
- Create and manage Compute instances and VNICs.
- Create, attach, and manage Block Volumes.
- Create and manage VCN resources when using the new-VCN option.
- Read and subscribe to OCI Marketplace listings.
- Create and run OCI Resource Manager stacks when using the deployment button.

Apply least-privilege IAM policies appropriate to your tenancy structure. Do not grant tenancy-wide `manage all-resources` solely for this deployment.

### Fortinet license

Before deployment:

- Obtain a compatible FortiManager-VM license or evaluation entitlement.
- Confirm that the license supports the selected device and VDOM capacity.
- Confirm that the license supports the allocated CPU capacity.
- Register the entitlement through the applicable Fortinet support account.
- Download the license file when file-based licensing is used.
- Allow the required connectivity to Fortinet registration services, or prepare the documented offline entitlement procedure.

See [Fortinet licensing for FortiManager on OCI](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide/583943/licensing).

### Terraform CLI

For CLI deployment, install:

- Terraform 1.0 or later
- Git
- OCI API signing-key credentials or another authentication method supported by the OCI Terraform provider

Store OCI credentials in `~/.oci/config`, protected environment variables, OCI instance-principal configuration, or another approved credential mechanism.

Never commit:

- Private keys
- Passwords
- License files
- `terraform.tfvars`
- Terraform state
- Saved Terraform plans
- OCI configuration files containing credentials

### Network planning

Choose non-overlapping CIDR ranges and determine how administrators and managed FortiGate devices will reach FortiManager.

For an existing network, verify that:

- The FortiManager private IP belongs to the selected management subnet.
- The private IP is not already assigned.
- Routes exist between FortiManager and all managed-device networks.
- Return routing is configured.
- DNS and NTP services are reachable.
- FortiGuard and Fortinet registration services are reachable when required.
- Security rules permit only required traffic.
- Changing the management subnet's route-table association is acceptable.

> [!CAUTION]
> The current existing-network workflow creates a new route table, adds a default route through the supplied Internet Gateway, and attaches that route table to the selected management subnet. This can change connectivity for other resources in the subnet.

## Security requirements

FortiManager is a privileged security-management system. Compromise of FortiManager can affect managed firewall configurations and policy deployments.

Prefer deploying FortiManager in a private subnet reachable through:

- Site-to-Site VPN
- FastConnect
- OCI Bastion
- A dedicated administrative VCN
- Approved VCN peering or DRG connectivity
- A protected on-premises management network

If temporary public management access is unavoidable:

1. Restrict TCP/443 to explicit administrator public CIDRs.
2. Enable TCP/22 only when SSH administration is required.
3. Never allow all protocols from `0.0.0.0/0`.
4. Restrict FGFM traffic to known managed FortiGate networks.
5. Restrict logging traffic to known devices and collectors.
6. Remove the public IP after private connectivity is established.
7. Configure trusted hosts for every FortiManager administrator.

Typical inbound flows include:

| Purpose | Protocol/port | Recommended source |
| --- | --- | --- |
| HTTPS administration and API | TCP/443 | Administrator, automation, or bastion CIDRs only |
| SSH administration | TCP/22 | Administrator or bastion CIDRs only; disable if unused |
| FortiGate FGFM management | TCP/541 | Known managed FortiGate networks |
| IPv6 FGFM management | TCP/541 or TCP/542, depending on version | Known managed FortiGate networks |
| Fortinet logging/OFTP | TCP/514 | Known managed devices only |
| Syslog | UDP/514 or TCP/514 | Known syslog clients only |
| Remote FortiGate GUI access | TCP/8082 | Only when this feature is required |
| FortiManager HA | TCP/5199 | Not required for this standalone deployment |

Additional ports may be required when FortiManager operates as:

- A local FortiGuard Distribution Server
- A FortiGuard rating server
- A logging or aggregation server
- A syslog server
- An API endpoint
- A remote FortiGate GUI proxy

Open only the ports required by enabled features. See the [FortiManager incoming-port reference](https://docs.fortinet.com/document/fortimanager/8.0.0/fortimanager-ports/465971/incoming-ports).

OCI recommends least-privilege NSG and security-list rules, private subnets for sensitive systems, and VCN Flow Logs. See [OCI secure network access recommendations](https://docs.oracle.com/en/solutions/oci-best-practices/ensure-secure-network-access1.html).

## Deployment with OCI Resource Manager

| FortiManager standalone |
| :---: |
| [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fmgstandalone/FortiManager_Standalone_Terraform.zip) |

To deploy:

1. Sign in to the intended OCI tenancy and region.
2. Select **Deploy to Oracle Cloud**.
3. Review the downloaded Terraform configuration before accepting it.
4. Select the compartment in which to create the Resource Manager stack.
5. Choose a supported Terraform version.
6. Configure all required inputs.
7. Use a specific trusted source CIDR after the Terraform security-rule implementation has been corrected.
8. Do not use `0.0.0.0/0` for administrator access.
9. Create the stack without automatically applying it.
10. Run and review a **Plan** job.
11. Confirm the image, shape, public IP behavior, routes, security rules, and Block Volume size.
12. Run **Apply** only after the plan has been approved.

For OCI Resource Manager requirements, see [Terraform configurations for Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm).

## Deployment with Terraform CLI

### 1. Clone the repository

```shell
git clone https://github.com/40net-cloud/fortinet-oci-solutions.git
cd fortinet-oci-solutions/FortiManager/terraform
```

### 2. Configure OCI authentication

Configure an OCI CLI profile in `~/.oci/config` or use another authentication method supported by the OCI Terraform provider.

Protect the private key and do not place private-key contents in Terraform files.

### 3. Create `terraform.tfvars`

The following example shows the principal inputs. Replace every example value with values from your OCI environment.

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

# Variable name retained for compatibility.
# This selects the FortiManager firmware image, not FortiOS.
fortios_version = "8.0.0"

vm_compute_shape = "VM.Standard2.2"

network_strategy             = "Create New VCN and Subnet"
vcn_display_name             = "FortiManager-VCN"
vcn_cidr_block               = "10.30.0.0/16"
vcn_dns_label                = "fmgvcn"
management_subnet_display_name = "fmg-management-subnet"
management_subnet_cidr_block = "10.30.1.0/24"
management_subnet_dns_label  = "management"
mgmt_private_ip_primary_a    = "10.30.1.10"

# Size according to the license and data/logging requirements.
volume_size = 500

# SECURITY NOTE:
# The current Terraform does not enforce this value.
# Do not rely on it until the NSG implementation has been corrected.
nsg_whitelist_ip = "203.0.113.10/32"
```

For an existing VCN:

```hcl
network_strategy     = "Use Existing VCN and Subnet"
vcn_id               = "ocid1.vcn.oc1..example"
management_subnet_id = "ocid1.subnet.oc1..example"
igw_ocid             = "ocid1.internetgateway.oc1..example"

# Must be an unused address in management_subnet_id.
mgmt_private_ip_primary_a = "10.30.1.10"
```

The existing-network workflow currently attaches a newly created route table to the selected management subnet. Review this behavior carefully before applying.

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

A saved plan may contain sensitive values. Store it securely and remove it after use. Never include it in a release archive.

Review at least:

- Selected FortiManager Marketplace image
- Firmware version
- Instance shape
- Availability domain and fault domain
- Public IP assignment
- Management private IP
- Security-list and NSG rules
- Default routes and Internet Gateway usage
- Changes to existing VCN resources
- Data-disk size and attachment type
- Marketplace agreement and subscription

### 6. Apply

```shell
terraform apply tfplan
```

Use a secure, access-controlled remote backend for team or production deployments. The current configuration does not define a remote state backend.

## Input variables

The authoritative inputs are defined in [`terraform/variables.tf`](terraform/variables.tf). The OCI Resource Manager UI schema is defined in [`terraform/marketplace.yaml`](terraform/marketplace.yaml).

Important variables include:

| Variable | Description |
| --- | --- |
| `compute_compartment_ocid` | Compartment for Compute, network, storage, and Marketplace resources |
| `region` | OCI deployment region |
| `availability_domain_name_1` | Availability domain for the instance and Block Volume |
| `fault_domain_name_1` | Fault domain for the instance |
| `license_type` | Marketplace license type; the current schema exposes `BYOL` |
| `cpu_type` | Image architecture; the current Resource Manager schema exposes `X64` |
| `fortios_version` | FortiManager firmware image version; the name should be corrected in a future breaking release |
| `vm_compute_shape` | OCI Compute shape |
| `network_strategy` | Create a new VCN/subnet or use existing resources |
| `management_subnet_id` | Existing management subnet when using an existing network |
| `mgmt_private_ip_primary_a` | Fixed private IP for the FortiManager management VNIC |
| `volume_size` | Additional data-disk size in GB |
| `mp_subscription_enabled` | Whether Terraform accepts and creates the Marketplace subscription |

The current schema contains variables copied from FortiGate HA templates. These fields do not mean that the following features are implemented:

- FortiManager HA
- Trust or untrust interfaces
- Heartbeat networks
- Floating IP addresses
- A secondary FortiManager instance
- Flexible Compute shapes
- Configurable VNIC attachment type
- Separate network and Compute compartments

Several displayed inputs are currently unused, including the instance display name, whitelist CIDR, VNIC type, subnet span, trust/untrust inputs, and public-IP selection.

## Outputs

After a successful apply, Terraform returns:

| Output | Description |
| --- | --- |
| `fortimanager_vm_a_public_ip` | Public IPv4 address assigned to the FortiManager management VNIC |

Retrieve the output with:

```shell
terraform output fortimanager_vm_a_public_ip
```

The instance OCID and private IP are not currently exported. Find them on the OCI Compute instance details page.

Adding these outputs is recommended:

- `fortimanager_instance_id`
- `fortimanager_private_ip`
- `fortimanager_public_ip`
- `fortimanager_https_url`
- `fortimanager_data_volume_id`

## Initial access and licensing

1. Wait for the OCI Compute instance to reach the **Running** state.
2. Copy the instance public or private IP, depending on the approved management path.
3. Copy the instance OCID from the OCI Console.
4. Browse to:

   ```text
   https://<management-ip>
   ```

5. Expect a certificate warning until a trusted certificate is installed.
6. Upload and activate the FortiManager license when prompted.
7. Allow FortiManager to restart after license activation.
8. Sign in with username `admin`.
9. Use the instance OCID as the initial password.
10. Change the administrator password immediately.
11. Create named administrator accounts and stop using the built-in shared account for routine administration.

Fortinet registration systems can take time to recognize a newly registered license. If a recently registered license is rejected, wait for the documented registration interval and try again.

FortiManager must validate its license with FortiGuard registration services within the documented validation window unless the offline entitlement procedure is used.

See [Connecting to FortiManager-VM on OCI](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide/859327).

## Initialize the data disk

FortiManager on OCI requires an additional disk. The default disk is used for the operating system, while the additional disk stores other data, including logs.

The disk size must be based on:

- Licensed device and VDOM capacity
- ADOM database requirements
- Revision history
- Logging and reporting usage
- Retention requirements
- Backup and operational growth
- FortiManager best-practice sizing

The current Terraform attaches the additional volume using the paravirtualized attachment type. Fortinet's OCI documentation describes an emulated attachment for the manual procedure. Verify the supported attachment type for the selected FortiManager image and version before production use.

After deployment:

1. Confirm that the additional OCI Block Volume is attached read/write.
2. Gracefully stop and start or reboot FortiManager.
3. Wait for the FortiManager GUI and CLI to become available.
4. Check LVM status:

   ```text
   execute lvm info
   ```

5. If the disk is shown as unused, start LVM disk management:

   ```text
   execute lvm start
   ```

6. Confirm the prompt.
7. Allow FortiManager to reboot.
8. Run `execute lvm info` again.
9. Confirm that the disk is shown as used.
10. Use the documented `execute lvm extend <disk>` procedure when adding later disks.

Always back up FortiManager and perform a graceful shutdown before changing disk configuration.

See [Adding a disk to FortiManager-VM on OCI](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide/31403).

## FortiManager initial configuration

After licensing and storage initialization, complete the following before onboarding production devices.

### System settings

- Configure a meaningful hostname.
- Configure the correct timezone.
- Configure trusted DNS servers.
- Configure redundant NTP servers.
- Install a trusted HTTPS certificate.
- Configure an administrative login banner if required.
- Configure email or external notification services.
- Configure SNMP or other approved monitoring.
- Confirm FortiGuard connectivity where required.

### Administrator access

- Change the built-in administrator password.
- Create named administrator accounts.
- Apply least-privilege administrator profiles.
- Configure trusted hosts.
- Enable MFA or enterprise authentication where supported.
- Separate interactive administrators from API or automation accounts.
- Store automation credentials in an approved secret manager.
- Review concurrent administrator and workspace settings.

### ADOM design

Plan ADOM structure before onboarding large numbers of devices.

Consider:

- FortiOS versions used by managed devices
- Administrative boundaries
- Business units and environments
- Policy ownership
- Compliance boundaries
- Device groups
- Upgrade sequencing
- ADOM revision and backup requirements

Do not arbitrarily upgrade an ADOM version. Confirm compatibility with all devices assigned to that ADOM.

### Device onboarding

Before authorizing a FortiGate:

1. Confirm routing between FortiManager and the FortiGate.
2. Allow TCP/541 only between approved device and FortiManager networks.
3. Confirm the FortiGate is configured to use the correct FortiManager address.
4. Verify the device identity and serial number.
5. Authorize only expected devices.
6. Import the configuration and policy using the planned workflow.
7. Review object conflicts and import reports.
8. Create a revision before making changes.
9. Run installation previews and policy checks before installing a policy package.

## Post-deployment hardening

Complete the following before production use:

- Replace the default certificate with a trusted certificate.
- Change the built-in administrator password.
- Create named administrator accounts.
- Enable MFA or enterprise authentication where supported.
- Configure administrator trusted hosts.
- Disable HTTP and unused administrative protocols.
- Restrict OCI security rules to approved sources.
- Restrict TCP/541 to known FortiGate networks.
- Remove the public IP after private connectivity is operational.
- Enable VCN Flow Logs.
- Configure OCI alarms and monitoring.
- Configure regular FortiManager configuration backups.
- Verify backup checksums and test restoration procedures.
- Protect managed-device credentials.
- Configure revision retention.
- Configure log retention and quotas when logging is enabled.
- Schedule database-intensive maintenance outside peak periods.
- Review policy package installation permissions.
- Separate read-only, policy-authoring, approval, and installation responsibilities where required.
- Document the deployed image, firmware, shape, license, storage, routes, ports, and recovery procedure.

This template is standalone. For business-critical management environments, evaluate a supported FortiManager HA design separately. Do not infer HA support from unused HA variables in the Resource Manager schema.

See the [FortiManager Best Practices Guide](https://docs.fortinet.com/document/fortimanager/8.0.0/best-practices).

## Validation and troubleshooting

### No instance was created

The instance resource is conditional on finding exactly one Marketplace package matching `license_type`, `cpu_type`, and `fortios_version`.

Verify that:

- The selected version exists in `final_listings.json`.
- The image is available in the selected region.
- `license_type` matches the Marketplace package.
- `cpu_type` matches the selected image.
- Marketplace terms can be accepted in the target compartment.
- The package-selection logic did not match zero or multiple images.

### The management private IP is rejected

Confirm that `mgmt_private_ip_primary_a`:

- Belongs to the selected management subnet CIDR.
- Is not the subnet gateway.
- Is not a broadcast or reserved address.
- Is not already assigned to another VNIC.

### The GUI is unreachable

Check:

- Public or private IP assignment
- Subnet route-table association
- Internet Gateway, VPN, FastConnect, peering, or Bastion connectivity
- OCI security lists
- Attached NSGs
- TCP/443 access
- FortiManager administrative-access settings
- FortiManager static routes
- Whether FortiManager is rebooting after license or LVM activation

### A FortiGate cannot connect to FortiManager

Check:

- TCP/541 routing and security rules in both directions
- DNS resolution if a hostname is used
- The configured central-management address on the FortiGate
- FortiManager device authorization status
- FortiGate serial number and identity
- NAT between the FortiGate and FortiManager
- FortiManager administrative domains and device assignment
- Clock synchronization on both systems

For IPv6 management, confirm the port required by the deployed FortiManager and FortiOS versions.

### The data disk is not visible

Confirm that:

- The Block Volume is in the same availability domain as the instance.
- The volume is attached read/write.
- The selected attachment type is supported.
- FortiManager was rebooted after attachment.
- `execute lvm info` detects the disk.

If necessary, follow the [Fortinet data-disk procedure](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide/31403).

### Resource Manager does not detect Terraform

Inspect the release ZIP.

The selected Resource Manager working directory must contain:

- At least one `.tf` file
- `marketplace.yaml`
- Any local files referenced by the Terraform configuration

For the deployment button, package the configuration at the ZIP root. Do not include `terraform/plan.tfplan`.

### A recently registered license is rejected

Fortinet registration systems may require time to recognize a newly registered license. Wait for the documented interval and retry.

Also verify:

- The license is for FortiManager-VM.
- The license matches the intended deployment and capacity.
- The license has not been activated on another VM contrary to its entitlement.
- System time and DNS are correct.
- FortiGuard registration services are reachable.
- The correct offline entitlement procedure is used for isolated environments.

## Upgrade and lifecycle guidance

Before upgrading:

- Review FortiManager release notes.
- Review the supported upgrade path.
- Back up the FortiManager configuration and database.
- Verify the backup checksum.
- Record the current firmware version.
- Confirm the target firmware supports the OCI shape.
- Confirm license compatibility.
- Review ADOM versions and managed FortiGate compatibility.
- Schedule upgrades outside production policy-installation windows.
- Test the upgrade in a non-production environment.

A FortiManager backup should be restored to the same firmware version from which it was created. See [FortiManager backup and restore best practices](https://docs.fortinet.com/document/fortimanager/8.0.0/best-practices/947124/backing-up-and-restoring-the-configuration).

Do not change `fortios_version` in Terraform and assume this performs an in-place FortiManager firmware upgrade. Changing the Marketplace image can cause instance replacement or other destructive behavior.

Review the Terraform plan carefully before changing:

- Image version
- Compute shape
- Availability domain
- Subnet
- Private IP
- Block Volume
- Network strategy

### Destroying the deployment

To remove resources managed by Terraform CLI:

```shell
terraform plan -destroy
terraform destroy
```

Before destruction:

- Back up FortiManager.
- Verify the backup.
- Confirm retention requirements.
- Export required logs and reports.
- Record managed-device configuration.
- Confirm how managed FortiGate devices will behave without FortiManager.
- Review whether the Block Volume will be deleted.
- Review backups and snapshots separately.
- Review Marketplace subscriptions separately.
- Confirm that external network resources are not assumed to be Terraform-managed.

## Cost considerations

This deployment can incur charges for:

- OCI Compute OCPUs and memory
- Boot Volume storage
- Additional Block Volume capacity and performance
- Block Volume backups and snapshots
- Public IPv4 addresses where applicable
- Network egress and cross-region traffic
- OCI monitoring and logging retention
- FortiManager licensing and support

Configure OCI budgets and cost alerts before production deployment.

Monitor:

- Compute utilization
- Disk growth
- Log retention
- Revision database growth
- Backup and snapshot storage
- Network egress
- Temporary files
- Additional automatically created resources

See the [FortiManager OCI Administration Guide](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide).

## Repository files

| File | Purpose |
| --- | --- |
| [`terraform/provider.tf`](terraform/provider.tf) | Terraform and OCI provider requirements |
| [`terraform/variables.tf`](terraform/variables.tf) | Terraform input variables and validations |
| [`terraform/locals.tf`](terraform/locals.tf) | Marketplace image-selection and deployment logic |
| [`terraform/compute.tf`](terraform/compute.tf) | FortiManager instance, Block Volume, and attachment |
| [`terraform/network.tf`](terraform/network.tf) | VCN, subnet, gateways, routes, security list, and NSG |
| [`terraform/data_sources.tf`](terraform/data_sources.tf) | OCI identity and network lookups |
| [`terraform/image_subscription.tf`](terraform/image_subscription.tf) | Marketplace agreement and subscription |
| [`terraform/output.tf`](terraform/output.tf) | Terraform outputs |
| [`terraform/marketplace.yaml`](terraform/marketplace.yaml) | OCI Resource Manager UI schema |
| [`terraform/final_listings.json`](terraform/final_listings.json) | Generated Marketplace listing and image metadata |
| [`terraform/build-orm/install.tf`](terraform/build-orm/install.tf) | Resource Manager packaging helper |

## Support

For template defects or documentation corrections, [open a GitHub issue](https://github.com/40net-cloud/fortinet-oci-solutions/issues) and include:

- Deployment method: Resource Manager or Terraform CLI
- OCI region and availability domain
- Terraform version
- OCI provider version
- Selected FortiManager version
- Selected Compute shape
- New or existing VCN selection
- Sanitized Terraform plan or Resource Manager job error

Do not include:

- Private keys
- Passwords
- FortiManager license files
- Terraform state
- Saved Terraform plans
- Complete OCIDs
- Public IP addresses
- FortiManager backups
- Managed-device credentials
- Other sensitive tenancy or network information

For FortiManager product, licensing, or operational support, use the applicable Fortinet support channel and consult:

- [FortiManager OCI Administration Guide](https://docs.fortinet.com/document/fortimanager-public-cloud/8.0.0/oci-administration-guide)
- [FortiManager Administration Guide](https://docs.fortinet.com/document/fortimanager/8.0.0/administration-guide)
- [FortiManager Best Practices Guide](https://docs.fortinet.com/document/fortimanager/8.0.0/best-practices)