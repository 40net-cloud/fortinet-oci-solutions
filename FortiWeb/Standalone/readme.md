# FortiWeb Standalone Deployment on Oracle Cloud Infrastructure

Deploy one standalone FortiWeb-VM on Oracle Cloud Infrastructure (OCI) using Terraform and the FortiWeb Marketplace image.

This template follows the same OCI deployment model used by the repo’s standalone FortiGate pattern, but it does not use a FortiGate-style bootstrap or cloud-init flow. FortiWeb is deployed directly from the OCI Marketplace image and configured through its normal management interfaces and OCI networking.

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
| FortiWeb-VM | One OCI Compute instance created from a matching FortiWeb Marketplace image |
| Management VNIC | Attached to the management subnet as the FortiWeb administrative interface |
| Trust VNIC | Attached to the trust subnet for backend or internal traffic handling |
| Public IP on management interface | Assigned for administration access when using the default public management model |
| Additional storage | One OCI Block Volume attached to the instance |
| VCN | Created when `network_strategy` is `Create New VCN and Subnets`; otherwise an existing VCN is used |
| Management subnet | Created or supplied for the admin interface |
| Trust subnet | Created or supplied for internal/inbound traffic segmentation |
| Internet Gateway | Created when a new VCN is created |
| Route tables | Default routes for the management and trust subnets |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |

## Architecture and interface roles

The current template creates a two-subnet layout:

| FortiWeb interface | OCI resource | Intended role in the template |
| --- | --- | --- |
| Management interface | Primary VNIC in the management subnet | Admin access and OCI connectivity |
| Trust interface | Secondary VNIC in the trust subnet | Internal or application-side segmentation |

The design is intentionally simple and follows the same single-compartment approach used elsewhere in this repo:

- one compartment is used for all deployed resources
- one management subnet is created for the public/admin side
- one trust subnet is created for service-side traffic
- FortiWeb is deployed directly from the OCI marketplace image without a FortiGate-style bootstrap routine

## Known limitations

Review these items before deploying to production.

### Default ingress and security

The new VCN workflow creates a permissive default security model. This is convenient for lab and proof-of-concept deployments but should be tightened before production use.

Recommended hardening:

- restrict admin access to trusted source IPs
- restrict SSH/HTTPS exposure to approved management ranges
- validate trust-side access paths before enabling application traffic
- replace broad allow-all rules with service-specific rules

### Existing network changes

When `network_strategy` is set to `Use Existing VCN and Subnets`, the template can attach route tables or otherwise alter the supplied network objects. Review the target network before using an existing VCN to avoid unintended routing or access changes.

### Public IP behavior

The management interface is designed to use a public IP for administrative access in the default deployment flow. Adjust the design if you need private-only administration, a bastion host, or a network load balancer in front of the appliance.

### Marketplace image support

The selected FortiWeb image version, license type, and OCI compute shape must all match the current Marketplace inventory in the target region. The authoritative options are defined in:

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
- manage block volumes and volume attachments
- subscribe to the OCI Marketplace listing

Use least-privilege IAM policies appropriate for your tenancy.

### FortiWeb licensing

The template supports the FortiWeb OCI Marketplace licensing model published for the target region. Confirm:

- the license type is valid for the selected image
- the selected version is available in your region
- the compute shape is supported by the chosen image
- the target availability domain supports the selected shape

## Deployment with OCI Resource Manager

1. Create a new OCI Resource Manager stack.
2. Upload the contents of the `terraform/` directory as the stack source.
3. Set the required OCI variables, such as:
   - tenancy OCID
   - user OCID
   - API key fingerprint
   - private key path
   - region
   - compartment OCID
4. Select the requested FortiWeb image version and compute shape.
5. Review and apply the stack.
6. Confirm the created VCN, subnets, and FortiWeb instance are present.

This repo includes the OCI Marketplace metadata needed for the stack to be consumed in the same general GUI-driven flow as the other OCI deployments.

## Deployment with Terraform CLI

From the `FortiWeb/Standalone/terraform` directory:

```bash
terraform init
terraform plan
terraform apply
```

To use a custom variable file:

```bash
terraform apply -var-file=terraform.tfvars
```

## Input variables

The deployment exposes the standard OCI and FortiWeb variables, including:

- `tenancy_ocid`
- `user_ocid`
- `fingerprint`
- `private_key_path`
- `region`
- `compartment_ocid`
- `availability_domain_name_1`
- `fault_domain_name_1`
- `license_type`
- `fortiweb_version`
- `cpu_type`
- `vm_compute_shape_x64`
- `ocpu_count`
- `memory_in_gbs`
- `boot_volume_size_in_gbs`
- `data_volume_size_in_gbs`
- `network_strategy`
- `vcn_id`
- `vcn_cidr_block`
- `management_subnet_cidr_block`
- `trust_subnet_cidr_block`
- `mgmt_private_ip`
- `trust_private_ip`
- `volume_size`

The template is designed to use a single compartment for all deployment resources and a simple two-subnet topology.

## Outputs

This stack exposes key deployment outputs, including:

- the selected marketplace listing information
- the deployed instance OCID
- the management subnet and trust subnet IDs
- the management public IP or associated endpoint details
- the selected image resource metadata

Check the Terraform outputs after deployment to confirm the expected network and instance details are present.

## Initial access

After the instance is created:

1. Get the public management IP from OCI console or Terraform outputs.
2. Open the FortiWeb management interface over HTTPS.
3. Log in using the FortiWeb instance credentials supplied by the Marketplace image or the configured admin method.
4. Complete the initial configuration and validate the service and backend paths.

If the instance uses a private-only management design, access through a bastion host or secured management network.

## Repository files

The FortiWeb standalone deployment includes:

- `terraform/compute.tf` — the FortiWeb instance and secondary VNIC configuration
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

- the selected FortiWeb image version and license
- the management access model
- subnet CIDR overlap and routing
- security rules and firewall policies
- OCI Marketplace availability in the target region

