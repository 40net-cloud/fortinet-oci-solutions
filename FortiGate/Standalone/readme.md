# FortiGate Standalone Deployment on Oracle Cloud Infrastructure

Deploy one standalone FortiGate-VM on Oracle Cloud Infrastructure (OCI) using Terraform and OCI Marketplace images.

The template supports OCI Resource Manager and Terraform CLI deployments, BYOL and PAYG licensing, x86 and Arm images, and new or existing OCI networks.

## Contents

- [What this template deploys](#what-this-template-deploys)
- [Architecture and interface roles](#architecture-and-interface-roles)
- [Known limitations](#known-limitations)
- [Supported licensing](#supported-licensing)
- [FortiOS versions and Compute shapes](#fortios-versions-and-compute-shapes)
- [Prerequisites](#prerequisites)
- [Security requirements](#security-requirements)
- [Deployment with OCI Resource Manager](#deployment-with-oci-resource-manager)
- [Deployment with Terraform CLI](#deployment-with-terraform-cli)
- [Input variables](#input-variables)
- [Outputs](#outputs)
- [Initial access and licensing](#initial-access-and-licensing)
- [Bootstrap configuration](#bootstrap-configuration)
- [Initialize the additional disk](#initialize-the-additional-disk)
- [Configure traffic forwarding](#configure-traffic-forwarding)
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
| FortiGate-VM | One OCI Compute instance created from a matching FortiGate Marketplace image |
| Primary VNIC | Attached to the management subnet as FortiGate `port1` |
| Secondary VNIC | Attached to the trust subnet as FortiGate `port2` |
| Public IP on `port1` | An automatically assigned ephemeral public IP |
| Public IP on `port2` | A reserved public IP associated with the configured trust private IP |
| Additional storage | One OCI Block Volume attached to the FortiGate instance |
| VCN | Created when `network_strategy` is `Create New VCN and Subnet`; otherwise, an existing VCN is used |
| Management subnet | Created or supplied for `port1` |
| Trust subnet | Created or supplied for `port2` |
| Internet Gateway | Created for a new VCN |
| Route tables | Default Internet Gateway routes for both new subnets |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |
| Bootstrap configuration | FortiOS CLI configuration supplied through instance user data |

The deployment does **not** create or configure:

- FortiGate HA
- A second FortiGate instance
- Load balancers
- Floating HA IP addresses
- A separate heartbeat interface
- A dedicated untrust or external subnet
- A protected application or workload subnet
- OCI route rules targeting FortiGate as a virtual appliance
- FortiGate firewall policies
- Source NAT or destination NAT policies
- IPsec VPNs
- Dynamic routing
- FortiManager registration
- FortiAnalyzer logging
- Trusted administrator accounts or MFA
- Automatic BYOL license injection
- A secure remote Terraform state backend

## Architecture and interface roles

The current template creates two FortiGate interfaces:

| FortiGate interface | OCI resource | Intended role in the template |
| --- | --- | --- |
| `port1` | Primary VNIC in the management subnet | Management and default route |
| `port2` | Secondary VNIC in the trust subnet | Route toward the VCN CIDR |

The bootstrap configures:

- `port1` with the fixed management private IP.
- `port1` administrative access for ping, HTTPS, SSH, HTTP, and FGFM.
- `port2` with the fixed trust private IP.
- A default route through the management-subnet gateway on `port1`.
- A route for the VCN CIDR through the trust-subnet gateway on `port2`.
- MTU 9000 on both interfaces.
- An OCI SDN connector.

> [!IMPORTANT]
> The terms `management` and `trust` do not describe a conventional external/internal FortiGate topology in the current implementation. Both newly created subnets receive default Internet Gateway routes, and both VNICs receive public IP addresses. Review and redesign the interface roles before using this template as an Internet-edge or east-west firewall.

A typical routed-firewall architecture would normally use clearly defined interfaces such as:

- Management
- External or untrust
- Internal or trust

It would also include protected subnet route tables that send traffic to the appropriate FortiGate private IP.

## Known limitations

Review these limitations before deployment.

### Allow-all ingress

The new VCN workflow attaches a security list that permits all protocols from `0.0.0.0/0` to both subnets.

This can expose:

- FortiGate HTTPS administration
- SSH administration
- HTTP administration
- FGFM
- Any FortiOS service enabled on either interface
- Any application service allowed by a later FortiGate configuration

Replace the allow-all rule with explicit, protocol-specific rules.

### Unenforced whitelist

The `nsg_whitelist_ip` input is displayed to users but is not referenced by the Terraform security rules.

Entering a trusted `/32` address does not currently restrict access.

### NSG is not attached

Terraform creates an NSG and two allow-all rules, but the NSG is not assigned to either FortiGate VNIC.

Attach purpose-specific NSGs to the relevant VNICs and remove the subnet-wide allow-all security list.

### Public IPs on both interfaces

The primary VNIC always receives an ephemeral public IP. The secondary VNIC always receives a reserved public IP.

The `use_existing_ip` input does not control this behavior.

### Source/destination checking

The secondary VNIC is created with:

```hcl
skip_source_dest_check = false
```

This means OCI continues to perform source/destination checking. A VNIC that forwards traffic or performs NAT generally requires source/destination checking to be disabled:

```hcl
skip_source_dest_check = true
```

See [OCI VNIC source/destination-check documentation](https://docs.oracle.com/en-us/iaas/Content/Network/Tasks/managingvnics_tasks-attach.htm).

### No protected-subnet route

The template does not create an OCI route table that sends protected workload traffic to a FortiGate private IP.

Consequently, deploying the template does not automatically place FortiGate in the application traffic path.

### Existing subnet mutation

When an existing network is selected, Terraform:

- Creates a new management route table.
- Creates a new trust route table.
- Adds a default route to the supplied Internet Gateway.
- Attaches the new route tables to the supplied subnets.

This can change connectivity for every resource using those subnets.

### Fixed `/24` bootstrap masks

The bootstrap uses `255.255.255.0` for both FortiGate interfaces regardless of the selected subnet CIDRs.

Using non-`/24` management or trust subnets can produce incorrect FortiOS interface configuration.

### Jumbo frames enabled by default

The bootstrap sets MTU 9000 on both interfaces.

Confirm that the entire traffic path supports jumbo frames before retaining this setting. Otherwise, use the OCI and FortiOS default MTU or configure a tested value.

### Debug outputs only

The Terraform configuration exports selected Marketplace package and configuration details but does not export the instance OCID, VNIC IDs, private IPs, public IPs, or HTTPS URL.

### Schema inconsistencies

The Resource Manager schema contains fields and outputs that do not match the Terraform implementation. Examples include:

- Output names that do not exist in Terraform.
- `cluster_ip` for a standalone deployment.
- Misspelled `Open FotiGate`.
- Inputs that are not used.
- Dependencies on a nonexistent generic `vm_compute_shape` input.
- A memory default that is not present in the allowed enum.
- Shape choices that should be verified against current Fortinet support.

## Supported licensing

OCI supports:

- Bring Your Own License (BYOL)
- Pay As You Go (PAYG)

The current Resource Manager schema exposes:

- `BYOL`
- `PAYGO 2 OCPUs`
- `PAYGO 4 OCPUs`
- `PAYGO 8 OCPUs`
- `PAYGO 16 OCPUs`
- `PAYGO 24 OCPUs`

Important licensing considerations:

- A BYOL deployment requires a compatible FortiGate-VM license.
- The BYOL license must support the selected CPU capacity.
- PAYG is billed through OCI Marketplace in addition to OCI infrastructure charges.
- PAYG FortiGate instances do not support VDOMs.
- BYOL and PAYG are not interchangeable on an existing VM.
- Do not attempt to inject a BYOL license into a PAYG instance.
- Do not assume a BYOL instance can be converted to PAYG.

See [FortiGate licensing order types for OCI](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/773155/order-types).

## FortiOS versions and Compute shapes

The current Resource Manager schema exposes these FortiOS versions:

- FortiOS 8.0.0
- FortiOS 7.6.7
- FortiOS 7.4.12

The authoritative available packages are the entries in [`terraform/final_listings.json`](terraform/final_listings.json) that match:

- License type
- CPU architecture
- FortiOS version
- PAYG OCPU package, where applicable

### x86 shapes

The current template exposes:

- `VM.Standard2.2`
- `VM.Standard2.4`
- `VM.Standard2.8`
- `VM.Standard2.16`
- `VM.Standard2.24`
- `VM.Standard.E4.Flex`
- `VM.Standard.E5.Flex`
- `VM.Standard.E6.Flex`

### Arm shape

The current template exposes:

- `VM.Standard.A1.Flex`

Confirm that:

- The selected Marketplace image supports the CPU architecture.
- The selected FortiOS version supports the shape.
- The shape is available in the target availability domain.
- The shape supports at least two VNICs.
- OCPU allocation matches the BYOL license or PAYG package.
- Memory is sufficient for the enabled FortiGate features.

Fortinet recommends at least 4 GB RAM for normal FortiGate-VM operation, with additional capacity for resource-intensive security services.

The current Fortinet documentation lists Standard2, E3 Flex, E4 Flex, E5 Flex, Standard.3 Flex, and A1 Flex families. Verify any additional template-listed shape, including E6 Flex, against the selected Marketplace image and current Fortinet support matrix.

See [FortiGate OCI instance-type support](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/456256).

## Prerequisites

### OCI account and permissions

Use a dedicated OCI compartment where practical.

The deployment principal needs permission to:

- Read tenancy and compartment information.
- Read availability domains and fault domains.
- Create and manage Compute instances.
- Create and manage VNICs and private IPs.
- Create and manage public IPs.
- Create and manage Block Volumes and attachments.
- Create and manage VCN resources.
- Read and subscribe to Marketplace listings.
- Create and run Resource Manager stacks when using OCI Resource Manager.

Apply least-privilege IAM policies appropriate to your tenancy.

### OCI service limits

Confirm capacity and service limits for:

- Compute shapes
- OCPUs
- Memory
- VNICs
- Reserved public IPs
- Block Volumes
- VCNs
- Subnets
- Route tables
- Security lists
- NSGs
- Internet Gateways

### FortiGate license

For BYOL:

- Obtain a compatible FortiGate-VM license.
- Confirm that the license matches the allocated CPU capacity.
- Register the entitlement through Fortinet.
- Download the license file or prepare the supported FortiFlex activation method.

For PAYG:

- Confirm the selected Marketplace package.
- Confirm hourly software charges.
- Confirm that VDOM restrictions are acceptable.

### Terraform CLI

For CLI deployment, install:

- Terraform 1.0 or later
- Git
- OCI API signing-key credentials or another supported OCI provider authentication method

Never commit:

- Private keys
- Passwords
- FortiGate license files
- FortiFlex tokens
- `terraform.tfvars`
- Terraform state
- Saved Terraform plans
- OCI configuration files containing credentials

### Network planning

Before deployment, define:

- Management network
- External or untrust network
- Internal or trust network
- Protected workload networks
- North-south traffic flows
- East-west traffic flows
- Default routes
- Return routes
- NAT requirements
- Public services
- Administrative source networks
- FortiManager and FortiAnalyzer connectivity
- DNS, NTP, FortiGuard, and logging destinations

Do not deploy until interface roles and routing are unambiguous.

## Security requirements

### Management access

Restrict FortiGate management to a dedicated management network.

At minimum:

- Allow TCP/443 only from approved administrator or bastion CIDRs.
- Allow TCP/22 only when SSH is required.
- Disable HTTP administrative access.
- Disable administrative access on data-plane interfaces unless explicitly required.
- Configure FortiGate administrator trusted hosts.
- Enable MFA or enterprise authentication.
- Use named administrator accounts.
- Apply least-privilege administrator profiles.

The current bootstrap enables:

```text
ping https ssh http fgfm
```

on `port1`. Remove `http` and any unused access protocols before production deployment.

See [FortiGate management-access best practices](https://docs.fortinet.com/document/fortigate/8.0.0/best-practices/127480/user-authentication-for-management-network-access).

### Data-plane access

OCI security rules and FortiGate policies are separate enforcement layers.

OCI rules should permit only the traffic that must reach the FortiGate VNIC. FortiGate policies should then inspect, control, and log that traffic.

Avoid subnet-wide allow-all rules.

For public services:

- Open only required application ports.
- Restrict management separately from application traffic.
- Use explicit FortiGate VIP and firewall policies.
- Enable applicable security profiles.
- Confirm return routing.
- Test asymmetric-routing behavior.

### Egress access

Restrict egress where operationally practical while allowing required destinations such as:

- DNS
- NTP
- FortiGuard
- Fortinet licensing and registration
- FortiManager
- FortiAnalyzer
- Syslog or SIEM
- Certificate authorities
- Update services
- Approved application destinations

## Deployment with OCI Resource Manager

> [!CAUTION]
> The published deployment archive must be verified before using the deployment button. OCI Resource Manager expects the working directory to contain at least one `.tf` file.

The deployment archive should place these files at its root:

- Terraform `.tf` files
- `marketplace.yaml`
- `final_listings.json`
- `cloudinit/bootstrap_vm-a.tpl`

The archive must not contain:

- `.terraform`
- Terraform state
- Saved plans such as `terraform/plan.tfplan`
- `terraform.tfvars`
- Private keys
- OCI credentials
- FortiGate license files
- FortiFlex tokens
- Local test artifacts

| FortiGate standalone |
| :---: |
| [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FortiGate_Standalone_Terraform.zip) |

To deploy:

1. Sign in to the intended OCI tenancy and region.
2. Select **Deploy to Oracle Cloud**.
3. Review the downloaded Terraform configuration.
4. Select the Resource Manager stack compartment.
5. Choose a supported Terraform version.
6. Select the license model.
7. Select the FortiOS version and CPU architecture.
8. Select a supported Compute shape.
9. Configure OCPUs and memory for a flexible shape.
10. Configure new or existing network resources.
11. Use specific administrator CIDRs rather than `0.0.0.0/0`.
12. Create the stack without automatically applying it.
13. Run and review a **Plan** job.
14. Verify all public IPs, routes, security rules, and VNIC settings.
15. Run **Apply** only after the plan is approved.

See [Terraform configurations for OCI Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm).

## Deployment with Terraform CLI

### 1. Clone the repository

```shell
git clone https://github.com/40net-cloud/fortinet-oci-solutions.git
cd fortinet-oci-solutions/FortiGate/Standalone/terraform
```

### 2. Configure OCI authentication

Configure `~/.oci/config` or another OCI Terraform provider authentication method.

Protect API private keys and do not place private-key contents in Terraform files.

### 3. Create `terraform.tfvars`

The following example uses an x86 flexible shape and BYOL licensing.

```hcl
tenancy_ocid             = "ocid1.tenancy.oc1..example"
user_ocid                = "ocid1.user.oc1..example"
fingerprint              = "00:00:00:00:00:00:00:00:00:00:00:00:00:00:00:00"
private_key_path         = "/secure/path/to/oci_api_key.pem"
region                   = "eu-frankfurt-1"
compute_compartment_ocid = "ocid1.compartment.oc1..example"

availability_domain_name_1 = "example-AD-1"
fault_domain_name_1        = "FAULT-DOMAIN-1"

license_type    = "BYOL"
cpu_type        = "X64"
fortios_version = "8.0.0"

vm_compute_shape_x64 = "VM.Standard.E4.Flex"
vm_compute_shape_arm = ""

ocpu_count   = 2
memory_in_gbs = 16

network_strategy = "Create New VCN and Subnet"

vcn_display_name = "FortiGate-Standalone-VCN"
vcn_cidr_block   = "10.40.0.0/16"
vcn_dns_label    = "fgtvcn"

management_subnet_display_name = "fgt-management-subnet"
management_subnet_cidr_block   = "10.40.1.0/24"
management_subnet_dns_label    = "management"
mgmt_private_ip                = "10.40.1.10"
mgmt_subnet_gateway            = "10.40.1.1"

trust_subnet_display_name = "fgt-trust-subnet"
trust_subnet_cidr_block   = "10.40.2.0/24"
trust_subnet_dns_label    = "trust"
trust_private_ip          = "10.40.2.10"
trust_subnet_gateway      = "10.40.2.1"

trust_public_ip_lifetime = "RESERVED"
volume_size              = 50

# SECURITY NOTE:
# The current Terraform does not enforce this value.
nsg_whitelist_ip = "203.0.113.10/32"
```

For an Arm deployment:

```hcl
cpu_type              = "ARM64"
vm_compute_shape_arm   = "VM.Standard.A1.Flex"
vm_compute_shape_x64   = ""
ocpu_count             = 2
memory_in_gbs          = 16
```

For PAYG, use an exact Marketplace package value:

```hcl
license_type = "PAYGO 2 OCPUs"
```

The PAYG package and allocated OCPUs must match.

For an existing VCN:

```hcl
network_strategy = "Use Existing VCN and Subnet"

vcn_id               = "ocid1.vcn.oc1..example"
management_subnet_id = "ocid1.subnet.oc1..management"
trust_subnet_id      = "ocid1.subnet.oc1..trust"
igw_ocid             = "ocid1.internetgateway.oc1..example"

mgmt_private_ip     = "10.40.1.10"
mgmt_subnet_gateway = "10.40.1.1"

trust_private_ip     = "10.40.2.10"
trust_subnet_gateway = "10.40.2.1"
```

> [!CAUTION]
> The existing-network workflow replaces the route-table associations on both supplied subnets with route tables created by this stack.

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

Saved Terraform plans can contain sensitive information. Store them securely and never include them in a release archive.

Review:

- Marketplace listing and image
- BYOL or PAYG selection
- FortiOS version
- CPU architecture
- Compute shape
- OCPUs and memory
- Public IP assignment on both VNICs
- Private IP addresses
- Route tables
- Internet Gateway routes
- Security lists
- NSGs and VNIC membership
- Source/destination-check settings
- Block Volume attachment
- Existing subnet changes
- Bootstrap user data

### 6. Apply

```shell
terraform apply tfplan
```

Use a secure remote backend for production Terraform state.

## Input variables

The authoritative variables are defined in [`terraform/variables.tf`](terraform/variables.tf). OCI Resource Manager metadata is defined in [`terraform/marketplace.yaml`](terraform/marketplace.yaml).

Important inputs include:

| Variable | Description |
| --- | --- |
| `compute_compartment_ocid` | Compartment for Compute, storage, networking, and Marketplace resources |
| `region` | OCI deployment region |
| `availability_domain_name_1` | Availability domain for the instance and Block Volume |
| `fault_domain_name_1` | Fault domain for the instance |
| `license_type` | BYOL or an exact PAYG OCPU package |
| `cpu_type` | `X64` or `ARM64` |
| `fortios_version` | FortiOS Marketplace image version |
| `vm_compute_shape_x64` | x86 Compute shape |
| `vm_compute_shape_arm` | Arm Compute shape |
| `ocpu_count` | OCPUs for supported flexible shapes |
| `memory_in_gbs` | Memory for supported flexible shapes |
| `network_strategy` | Create new networking or use existing resources |
| `management_subnet_id` | Existing management subnet |
| `trust_subnet_id` | Existing trust subnet |
| `mgmt_private_ip` | Fixed private IP for `port1` |
| `trust_private_ip` | Fixed private IP for `port2` |
| `trust_public_ip_lifetime` | Lifetime of the public IP assigned to the trust private IP |
| `volume_size` | Additional Block Volume size in GB |
| `mp_subscription_enabled` | Whether to accept and create the Marketplace subscription |
| `bootstrap_vm-a` | Path to the FortiGate bootstrap template |

Some displayed inputs are not currently implemented, including:

- `vm_display_name`
- `vm_flex_shape_ocpus`
- `instance_launch_options_network_type`
- `subnet_span`
- `nsg_whitelist_ip`
- `use_existing_ip`

Do not assume that changing these values changes the deployment.

## Outputs

The current Terraform exports debug information:

- `selected_fortigate_package`
- `selected_image_id`
- `selected_configuration`

It does not export the actual deployed instance or VNIC addresses.

Recommended outputs include:

- FortiGate instance OCID
- FortiGate instance state
- Management private IP
- Management public IP
- Trust private IP
- Trust public IP
- Management VNIC OCID
- Trust VNIC OCID
- HTTPS management URL
- Block Volume OCID

Until these outputs are added, retrieve addresses from the OCI Console.

## Initial access and licensing

1. Wait for the OCI Compute instance to reach **Running**.
2. Open the instance details in the OCI Console.
3. Copy the management public or private IP.
4. Copy the instance OCID.
5. Browse to:

   ```text
   https://<management-ip>
   ```

6. Expect a certificate warning until a trusted certificate is installed.
7. Sign in with username `admin`.
8. Use the instance OCID as the initial password.
9. For BYOL, activate the FortiGate license.
10. Allow FortiGate to reboot if required.
11. Change the administrator password immediately.
12. Create named administrator accounts.
13. Configure trusted hosts and MFA.

See [Accessing FortiGate-VM on OCI](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/721704/accessing-the-fortigate-vm).

PAYG instances should use the PAYG Marketplace entitlement. Do not upload a BYOL license to a PAYG instance.

## Bootstrap configuration

The template applies [`terraform/cloudinit/bootstrap_vm-a.tpl`](terraform/cloudinit/bootstrap_vm-a.tpl) as instance user data.

The bootstrap configures:

- Hostname `FortiGate-A`
- Administrator timeout of 60 minutes
- `port1` as management
- `port2` as trust
- HTTP, HTTPS, SSH, ping, and FGFM access on `port1`
- MTU 9000 on both interfaces
- OCI SDN connector
- Default route through `port1`
- VCN CIDR route through `port2`

After deployment, verify:

```text
show system interface
get router info routing-table all
show system sdn-connector
```

Confirm that:

- Interface IPs match the OCI VNIC IPs.
- Interface masks match the actual subnet CIDRs.
- Default and VCN routes are correct.
- MTU is supported end-to-end.
- Unused administrative protocols are disabled.
- The OCI SDN connector is required and functional.
- Required OCI IAM dynamic-group policies are configured if the connector uses OCI APIs.

The bootstrap currently sets `ha-status enable` on the OCI connector even though this is a standalone deployment. Review whether that setting is appropriate.

## Initialize the additional disk

The template creates a 50 GB Block Volume and attaches it using the paravirtualized attachment type.

Fortinet's OCI guide describes attaching approximately 50 GB using the emulated attachment type and rebooting FortiGate afterward.

Verify the attachment type supported by the selected FortiOS image.

After deployment:

1. Confirm that the Block Volume is attached read/write.
2. Gracefully reboot or stop/start FortiGate.
3. Verify disk detection from FortiOS.
4. Confirm the disk is available for the intended logging or storage function.

See [Attaching storage to FortiGate-VM on OCI](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide/557176).

## Configure traffic forwarding

Deploying the VM does not automatically place FortiGate in the traffic path.

Before forwarding production traffic:

### 1. Define interface roles

Determine which interface is:

- Management
- External or untrust
- Internal or trust

If necessary, create a third VNIC or redesign the two-interface topology.

### 2. Disable source/destination checking

For every VNIC that forwards traffic or performs NAT, set:

```hcl
skip_source_dest_check = true
```

The current template sets this to `false` on the secondary VNIC and does not explicitly disable it on the primary VNIC.

### 3. Create protected-subnet routes

For a protected application subnet, configure an OCI route such as:

```text
Destination: 0.0.0.0/0
Target type: Private IP
Target: FortiGate internal/trust private IP
```

Use more specific destinations where required.

### 4. Configure return routing

Ensure return traffic follows the same FortiGate path. Avoid asymmetric routing.

### 5. Configure FortiGate policies

Create only the required:

- Firewall policies
- Source NAT
- Destination NAT and VIPs
- Security profiles
- Static or dynamic routes
- Logging
- Administrative-access settings

### 6. Test before production

Validate:

- North-south flows
- East-west flows
- Return routing
- NAT
- Health checks
- MTU and fragmentation
- Fail-closed behavior
- Logging
- FortiGuard connectivity

## Post-deployment hardening

Complete the following before production use:

- Replace the default HTTPS certificate.
- Change the built-in administrator password.
- Create named administrator accounts.
- Configure least-privilege access profiles.
- Enable MFA or enterprise administrator authentication.
- Configure administrator trusted hosts.
- Remove HTTP administrative access.
- Disable SSH if it is not required.
- Disable administrative access on data interfaces.
- Restrict OCI security rules.
- Attach NSGs to the appropriate VNICs.
- Remove the allow-all security list.
- Remove unnecessary public IP addresses.
- Disable source/destination checking only on forwarding VNICs.
- Configure FortiGuard connectivity.
- Configure trusted DNS and NTP servers.
- Configure FortiAnalyzer, FortiManager, syslog, or SIEM logging.
- Configure automatic backups.
- Enable OCI VCN Flow Logs.
- Configure OCI alarms and budgets.
- Review FortiOS local-in policies.
- Apply tested firewall policies and security profiles.
- Verify license and support entitlement.
- Record interface roles, routes, NAT, policies, public IPs, and recovery procedures.

## Validation and troubleshooting

### No FortiGate instance was created

The instance is conditional on matching exactly one Marketplace package.

Verify:

- `license_type`
- `cpu_type`
- `fortios_version`
- PAYG OCPU package
- Region availability
- Marketplace subscription
- Entries in `final_listings.json`

### Flexible shape configuration fails

Confirm that:

- The shape is supported by the OCI region.
- The image supports the selected shape.
- `ocpu_count` is valid for the shape.
- `memory_in_gbs` is valid for the OCPU allocation.
- The selected license supports the allocated OCPUs.
- The Resource Manager schema did not supply an invalid default.

### The management GUI is unreachable

Check:

- Management public or private IP
- Management subnet route table
- Internet Gateway, VPN, FastConnect, or Bastion path
- OCI security lists and NSGs
- FortiGate `allowaccess`
- TCP/443
- FortiGate static routes
- Whether FortiGate is rebooting after licensing
- Whether bootstrap completed successfully

### The second interface is unavailable

Check:

- VNIC attachment state
- Shape VNIC limits
- Private IP assignment
- FortiOS interface mapping
- Subnet availability domain compatibility
- Bootstrap output
- `show system interface`

### Traffic does not pass through FortiGate

Check:

- Protected-subnet route table
- Route target private IP
- Source/destination-check setting
- FortiGate firewall policy
- NAT
- FortiGate routing table
- OCI security rules
- Return routing
- Asymmetric routing
- Interface roles
- MTU

### Bootstrap configuration is incorrect

The bootstrap assumes `/24` subnet masks and MTU 9000.

If the selected networks differ:

- Correct the template variables and masks.
- Correct the FortiOS interface configuration.
- Verify gateways.
- Verify the VCN CIDR route.
- Reapply the configuration safely.

### The additional disk is not visible

Check:

- Availability domain
- Attachment state
- Attachment type
- Read/write access
- FortiGate reboot status
- FortiOS disk detection

### Resource Manager does not detect Terraform

Inspect the release ZIP.

The Resource Manager working directory must contain the `.tf` files. For the deployment button, package the Terraform configuration and `marketplace.yaml` at the archive root.

Do not include `terraform/plan.tfplan`.

## Upgrade and lifecycle guidance

Before upgrading FortiOS:

- Review FortiOS release notes.
- Review the supported upgrade path.
- Back up the FortiGate configuration.
- Verify the backup.
- Confirm target-image shape support.
- Confirm license compatibility.
- Confirm FortiManager ADOM compatibility, if managed.
- Confirm FortiAnalyzer compatibility.
- Schedule a maintenance window.
- Test the upgrade in a non-production environment.

Do not change `fortios_version` in Terraform and assume Terraform performs an in-place FortiOS upgrade. Changing the Marketplace image can replace the instance.

Review plans carefully before changing:

- License model
- FortiOS version
- CPU architecture
- Compute shape
- OCPU allocation
- Availability domain
- VCN or subnet
- Private IP
- Public IP
- Block Volume
- Bootstrap configuration

BYOL and PAYG cannot be converted in place.

### Destroying the deployment

To remove resources managed by Terraform CLI:

```shell
terraform plan -destroy
terraform destroy
```

Before destruction:

- Back up FortiGate.
- Export required logs.
- Review the destroy plan.
- Confirm Block Volume retention.
- Confirm public IP behavior.
- Confirm protected-subnet routes no longer target FortiGate.
- Confirm workload connectivity after removal.
- Review Marketplace subscription handling.
- Review backups and snapshots separately.

## Cost considerations

This deployment can incur charges for:

- OCI Compute OCPUs and memory
- PAYG Marketplace software charges
- Boot Volume storage
- Additional Block Volume storage
- Reserved public IP addresses
- Network egress
- Cross-region traffic
- Backups and snapshots
- OCI monitoring and logging
- FortiGate BYOL licensing and support

PAYG Marketplace charges and OCI infrastructure charges are separate.

Configure OCI budgets and cost alerts before production deployment.

## Repository files

| File | Purpose |
| --- | --- |
| [`terraform/provider.tf`](terraform/provider.tf) | Terraform and OCI provider requirements |
| [`terraform/variables.tf`](terraform/variables.tf) | Terraform input variables |
| [`terraform/locals.tf`](terraform/locals.tf) | Marketplace package and shape-selection logic |
| [`terraform/compute.tf`](terraform/compute.tf) | FortiGate instance, VNIC, public IP, bootstrap, and disk resources |
| [`terraform/network.tf`](terraform/network.tf) | VCN, subnets, gateways, routes, security list, and NSG |
| [`terraform/data_sources.tf`](terraform/data_sources.tf) | OCI identity and network lookups |
| [`terraform/image_subscription.tf`](terraform/image_subscription.tf) | Marketplace agreement and subscription |
| [`terraform/debug_outputs.tf`](terraform/debug_outputs.tf) | Marketplace-selection debug outputs |
| [`terraform/marketplace.yaml`](terraform/marketplace.yaml) | OCI Resource Manager UI schema |
| [`terraform/final_listings.json`](terraform/final_listings.json) | Generated Marketplace listing and image metadata |
| [`terraform/cloudinit/bootstrap_vm-a.tpl`](terraform/cloudinit/bootstrap_vm-a.tpl) | Initial FortiOS CLI configuration |
| [`terraform/build-orm/install.tf`](terraform/build-orm/install.tf) | Resource Manager packaging helper |

## Support

For template defects or documentation corrections, [open a GitHub issue](https://github.com/40net-cloud/fortinet-oci-solutions/issues) and include:

- Deployment method
- OCI region and availability domain
- Terraform version
- OCI provider version
- FortiOS version
- License model
- CPU architecture
- Compute shape
- OCPUs and memory
- New or existing network selection
- Sanitized Terraform or Resource Manager error
- Relevant FortiOS diagnostic output with sensitive data removed

Do not include:

- Private keys
- Passwords
- FortiGate license files
- FortiFlex tokens
- Terraform state
- Saved Terraform plans
- Full OCIDs
- Public IP addresses
- Configuration backups
- API tokens
- Sensitive network information

For product, licensing, or operational support, use the applicable Fortinet support channel and consult:

- [FortiGate OCI Administration Guide](https://docs.fortinet.com/document/fortigate-public-cloud/8.0.0/oci-administration-guide)
- [FortiOS Administration Guide](https://docs.fortinet.com/document/fortigate/8.0.0/administration-guide)
- [FortiGate Security Best Practices](https://docs.fortinet.com/document/fortigate/8.0.0/best-practices)