# FortiWeb Active/Active Deployment on Oracle Cloud Infrastructure

Deploy two FortiWeb-VM instances in active/active high-availability mode behind an OCI Network Load Balancer (NLB) using Terraform and the FortiWeb Marketplace image.

This stack follows the same OCI deployment pattern used by the rest of this repository, but it is tailored for an active/active model in which both FortiWeb nodes process traffic through the same public NLB endpoint. The configuration supports either a new VCN/subnet layout or an existing-network deployment model.

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
| FortiWeb-A | One OCI Compute instance created from the selected FortiWeb Marketplace image |
| FortiWeb-B | A second OCI Compute instance created in a separate fault domain and availability domain or same AD depending on deployment inputs |
| Public NLB | OCI Network Load Balancer placed in a public subnet and configured with a backend set and listener |
| FortiWeb untrusted subnet | One shared untrusted subnet for both FortiWeb `port1` interfaces |
| Additional storage | One OCI Block Volume attached to each FortiWeb instance |
| VCN | Created when `network_strategy` is `Create New VCN and Subnets`; otherwise an existing VCN is used |
| NLB subnet | Created or supplied for the public NLB endpoint |
| Internet Gateway | Created when a new VCN is created |
| Route tables and security lists | Created for NLB and FortiWeb traffic paths |
| Marketplace agreement | Accepted and subscribed when `mp_subscription_enabled` is `true` |

## Architecture and interface roles

The current active/active template is designed for a two-node, load-balanced FortiWeb deployment.

| FortiWeb interface | OCI resource | Intended role in the template |
| --- | --- | --- |
| `port1` | Primary VNIC in the untrusted subnet | Front-end traffic path for the NLB and direct management access when public IPs are enabled |
| `lb` subnet | Public NLB subnet | Publishes the active/active application endpoint |
| `untrust` subnet | Shared FortiWeb traffic subnet | Hosts both FortiWeb primary interfaces and the backend traffic path from the NLB |

The design includes the following key characteristics:

- two FortiWeb instances are deployed in parallel
- each FortiWeb instance is attached to the same untrusted subnet for application traffic
- the public NLB listens on the application endpoint and forwards traffic to both FortiWeb backends
- active/active behavior is achieved by placing both FortiWeb nodes behind the same NLB backend set
- both FortiWeb instances deploy with separate availability domain and fault domain placement inputs for resilience

## Known limitations

Review these items before deploying to production.

### Default ingress and security

The new VCN workflow creates a permissive default security model. This is useful for lab and proof-of-concept deployments, but it should be hardened before production use.

Recommended hardening:

- restrict application traffic to trusted client CIDRs via `application_ingress_cidr`
- restrict direct administrator access through `admin_ingress_cidr`
- validate health-check and application paths before exposing the endpoint broadly
- replace broad allow-all rules with service-specific rules

### Existing network changes

When `network_strategy` is set to `Use Existing VCN and Subnets`, the template can attach route tables or otherwise alter the supplied network objects. Review the target network before using an existing VCN to avoid unexpected routing or access changes.

### Public IP behavior

The template can assign public IPs to the FortiWeb untrusted interfaces when `assign_public_ip` is enabled. This is convenient for direct administration, but private-only management can be used when a bastion host or private networking is preferred.

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
- create and manage VCNs, route tables, subnets, gateways, and load balancers
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

| FortiWeb Active/Active (New VCN) | FortiWeb Active/Active (Existing VCN) |
| :---: | :---: |
| [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/tf-fwb-activeactive-newvcn.zip) | [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/tf-fwb-activeactive-existingvcn.zip) |

Use the stack in the `FortiWeb/Active-Active/terraform` directory as the deployment package for OCI Resource Manager.

To package the stack for Resource Manager, run the following command from this directory:

```bash
zip -r fortiweb-active-active.zip . \
  -x '.terraform/*' '*.tfstate*' '*.tfplan' 'fortiweb-active-active.zip'
```

To deploy:

1. Sign in to the intended OCI tenancy and region.
2. Upload or reference the generated `fortiweb-active-active.zip` in OCI Resource Manager.
3. Review the Terraform configuration and stack inputs.
4. Select the target compartment and workload region.
5. Choose the FortiWeb license model and version.
6. Select a supported OCI compute shape and adjust OCPUs and memory for flex shapes.
7. Configure the network strategy, VCN, and subnet values.
8. Use specific administrator and application CIDRs rather than `0.0.0.0/0`.
9. Create the stack without automatically applying it.
10. Run and review a Plan job.
11. Verify the VCN, subnets, route tables, NLB, and FortiWeb instance configuration.
12. Run Apply only after the plan is approved.

See [Terraform configurations for OCI Resource Manager](https://docs.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/terraformconfigresourcemanager.htm) for more detail.

## Deployment with Terraform CLI

From the `FortiWeb/Active-Active/terraform` directory:

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
- `compartment_ocid`
- `network_compartment_ocid`
- `region`
- `prefix`
- `availability_domain_name_a`
- `fault_domain_name_a`
- `availability_domain_name_b`
- `fault_domain_name_b`
- `license_type`
- `fortiweb_version`
- `cpu_type`
- `vm_compute_shape_x64`
- `ocpu_count`
- `memory_in_gbs`
- `boot_volume_size_in_gbs`
- `data_volume_size_in_gbs`
- `mp_subscription_enabled`
- `network_strategy`
- `vcn_id`
- `lb_subnet_id`
- `untrust_subnet_id`
- `vcn_cidr_block`
- `lb_subnet_cidr`
- `untrust_subnet_cidr`
- `fwba_untrust_ip`
- `fwbb_untrust_ip`
- `application_ingress_cidr`
- `admin_ingress_cidr`
- `assign_public_ip`
- `health_check_port`

The template is designed to use a single compartment for all deployment resources and a shared active/active front-end pattern through the OCI NLB.

## Outputs

This stack exposes key deployment outputs, including:

- the selected marketplace listing information
- the FortiWeb-A instance OCID
- the FortiWeb-B instance OCID
- the public IP of the NLB
- the FortiWeb-A and FortiWeb-B management URLs when public IP assignment is enabled
- the selected image resource metadata

Check the Terraform outputs after deployment to confirm the expected network, load balancer, and instance details are present.

## Initial access

After the instance is created:

1. Get the NLB public IP from OCI console or Terraform outputs.
2. Open the application endpoint through the NLB.
3. Use the FortiWeb management URLs for each node when direct public access is enabled.
4. Log in with the credentials supplied by the Marketplace image or the configured admin method.
5. Complete the initial FortiWeb configuration and validate the active/active service path.

If the instance uses a private-only management design, access through a bastion host or secured management network.

## Repository files

The FortiWeb active/active deployment includes:

- `terraform/compute.tf` — the FortiWeb instances and their VNIC configuration
- `terraform/network.tf` — VCN, subnets, route tables, security lists, NLB, and backend configuration
- `terraform/image_subscription.tf` — OCI Marketplace subscription and listing agreement
- `terraform/locals.tf` — marketplace selection logic and shape resolution
- `terraform/variables.tf` — deployment input variables
- `terraform/outputs.tf` — Terraform outputs
- `terraform/marketplace.yaml` — OCI stack metadata for GUI-driven deployment
- `terraform/final_listings.json` — authoritative marketplace inventory snapshot
- `terraform/customdatafwba.tpl` and `terraform/customdatafwbb.tpl` — per-node bootstrapping payloads

## Support

This repository is intended as an OCI deployment reference. Validate all IP addressing, network routing, and image availability against your tenancy before production rollout.

For production use, review:

- the selected FortiWeb image version and license
- the public versus private management model
- subnet CIDR overlap and routing
- NLB backend health checks and application path validation
- security rules and firewall policies
- OCI Marketplace availability in the target region
