# FortiSandbox Standalone Deployment on Oracle Cloud Infrastructure

Deploy one standalone FortiSandbox-VM on Oracle Cloud Infrastructure (OCI) using Terraform and the FortiSandbox Marketplace image.

This template follows the same OCI deployment model used by the repo’s standalone FortiGate and FortiWeb patterns, but it is tuned for a single-primary-VNIC FortiSandbox deployment.

## Contents

- [What this template deploys](#what-this-template-deploys)
- [Architecture and interface roles](#architecture-and-interface-roles)
- [Known limitations](#known-limitations)
- [Prerequisites](#prerequisites)
- [Deployment with OCI Resource Manager](#deployment-with-oci-resource-manager)
- [Deployment with Terraform CLI](#deployment-with-terraform-cli)
- [Input variables](#input-variables)
- [Outputs](#outputs)
- [Initial access](#initial-access)
- [Repository files](#repository-files)
- [Support](#support)

## What this template deploys

The Terraform configuration creates or uses the following resources:

| Resource | Behavior |
| --- | --- |
| FortiSandbox-VM | One OCI Compute instance created from the matching FortiSandbox Marketplace image |
| Primary VNIC (`port1`) | Attached to the frontend subnet for management and application traffic |
| Public IP on management interface | Assigned when `assign_public_ip` is enabled |
| Frontend NSG | Controls management and client ingress access |
| VCN | Created when `network_strategy` is `Create New VCN and Subnets`; otherwise an existing VCN is used |
| Frontend subnet | Created or supplied for the management and client-facing side |
| Frontend subnet | Created or supplied for all FortiSandbox traffic on `port1` |
| Internet Gateway | Created when a new VCN is created |
| Route table | Default route for the frontend subnet |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |

## Architecture and interface roles

The current template creates a single-subnet layout:

| FortiSandbox interface | OCI resource | Intended role in the template |
| --- | --- | --- |
| `port1` | Primary VNIC in the frontend subnet | Management and application connectivity |

The design keeps the deployment simple and consistent with the repo’s standalone OCI patterns:

- one compartment is used for all deployed resources
- one subnet is created or supplied for all management and application traffic
- FortiSandbox is deployed directly from the OCI Marketplace image without a custom bootstrap routine

## Known limitations

Review these items before deploying to production.

### Default ingress and security

The new VCN workflow creates a permissive default security model. This is useful for lab and proof-of-concept deployments, but it should be tightened before production use.

Recommended hardening:

- restrict management access to trusted source IPs
- restrict HTTPS and SSH exposure to approved management ranges
- validate application access paths before enabling application traffic
- replace broad allow-all rules with service-specific rules

### Existing network changes

When `network_strategy` is set to `Use Existing VCN and Subnets`, the template reuses the supplied network objects. Review the target network before deploying to avoid unintended routing or access changes.

### Public IP behavior

The frontend interface is designed to use a public IP for administrative access in the default deployment flow. Adjust the design if you need private-only administration, a bastion host, or a network load balancer in front of the appliance.

### Marketplace image support

The selected FortiSandbox image version, license type, and OCI compute shape must all match the current Marketplace inventory in the target region. The authoritative options are defined in:

- `terraform/final_listings.json`
- `terraform/locals.tf`
- `terraform/variables.tf`

## Prerequisites

### OCI account and permissions

Your OCI principal must have permission to:

- read tenancy and compartment metadata
- read availability domains and fault domains
- create compute instances and VNICs
- create and manage public IPs
- create and manage VCNs, route tables, subnets, and gateways
- manage security rules and network security groups
- subscribe to the OCI Marketplace listing

Use least-privilege IAM policies appropriate for your tenancy.

### FortiSandbox licensing

The template supports the FortiSandbox OCI Marketplace licensing model published for the target region. Confirm:

- the license type is valid for the selected image
- the selected version is available in your region
- the compute shape is supported by the chosen image
- the target availability domain supports the selected shape

## Deployment with OCI Resource Manager

| FortiSandbox standalone |
| :---: |
| [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fsbstandalone/FortiSandbox_Standalone_Terraform.zip) |

To deploy:

1. Sign in to the intended OCI tenancy and region.
2. Select **Deploy to Oracle Cloud**.
3. Review the downloaded Terraform configuration.
4. Select the Resource Manager stack compartment.
5. Choose a supported Terraform version.
6. Select the FortiSandbox license model.
7. Select the FortiSandbox version and compute shape.
8. Configure new or existing network resources.
9. Set the management CIDRs and client ingress rules.
10. Create the stack without automatically applying it.
11. Run and review a **Plan** job.
12. Verify the VCN, route tables, subnets, and public management IP configuration.
13. Run **Apply** only after the plan is approved.

See [Terraform configurations for OCI Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm).

## Deployment with Terraform CLI

From the `FortiSandbox/Standalone/terraform` directory:

```bash
terraform init
terraform plan
terraform apply
```

To use a custom variable file:

```bash
terraform apply -var-file=terraform.tfvars
```

For an existing network, set:

```hcl
network_strategy   = "Use Existing VCN and Subnets"
vcn_id             = "ocid1.vcn.oc1..."
frontend_subnet_id = "ocid1.subnet.oc1..."
```

The frontend subnet must permit public IP assignment if `assign_public_ip` is `true`. Its route table must provide the required path to an internet gateway.

## Input variables

The deployment exposes the standard OCI and FortiSandbox variables, including:

- `tenancy_ocid`
- `user_ocid`
- `fingerprint`
- `private_key_path`
- `region`
- `compartment_ocid`
- `availability_domain_name`
- `fault_domain_name`
- `license_type`
- `fortisandbox_version`
- `vm_compute_shape`
- `boot_volume_size_in_gbs`
- `network_strategy`
- `vcn_id`
- `vcn_cidr`
- `frontend_subnet_cidr`
- `frontend_private_ip`
- `assign_public_ip`
- `management_cidr`
- `client_ingress_cidr`
- `client_port_min`
- `client_port_max`

The template is designed to use a single compartment for all deployment resources and a simple one-subnet topology.

## Outputs

This stack exposes key deployment outputs, including:

- the selected marketplace listing information
- the deployed instance OCID
- the frontend subnet ID
- the management public IP or associated endpoint details
- the selected image resource metadata
- the sensitive initial password output

Check the Terraform outputs after deployment to confirm the expected network and instance details are present.

## Initial access

After the instance is created:

1. Get the public management IP from OCI console or Terraform outputs.
2. Open the FortiSandbox management interface over HTTPS.
3. Log in using the initial FortiSandbox credentials supplied by the Marketplace image or configured admin method.
4. Complete the initial configuration and validate the application path.

If the instance uses a private-only management design, access through a bastion host or secured management network.

## Repository files

The FortiSandbox standalone deployment includes:

- `terraform/compute.tf` — the FortiSandbox instance and primary VNIC configuration
- `terraform/network.tf` — VCN, subnets, route tables, and gateway resources
- `terraform/image_subscription.tf` — OCI Marketplace subscription and listing agreement
- `terraform/locals.tf` — marketplace selection logic and shape resolution
- `terraform/variables.tf` — deployment input variables
- `terraform/outputs.tf` — Terraform outputs
- `terraform/marketplace.yaml` — OCI stack metadata for GUI-driven deployment
- `terraform/final_listings.json` — authoritative marketplace inventory snapshot

## Support

This repository is intended as an OCI deployment reference. Validate all IP addressing, network routing, and image availability against your tenancy before production rollout.

For production use, review:

- the selected FortiSandbox image version and licensing model
- the management access model
- subnet CIDR overlap and routing
- security rules and firewall policies
- OCI Marketplace availability in the target region

## References

- [FortiSandbox OCI deployment guide](https://docs.fortinet.com/document/fortisandbox-public-cloud/latest/oracle-cloud-infrastructure-deployment-guide)
- [OCI Marketplace subscriptions in Terraform](https://docs.oracle.com/en-us/iaas/Content/Marketplace/Tasks/subscribe-terraform-configurations.htm)
- [FortiGate standalone reference template](https://github.com/40net-cloud/fortinet-oci-solutions/tree/main/FortiGate/Standalone)
- [FortiWeb standalone reference template](https://github.com/40net-cloud/fortinet-oci-solutions/tree/main/FortiWeb/Standalone)
