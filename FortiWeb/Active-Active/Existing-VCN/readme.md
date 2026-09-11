# FortiWeb Active/Active Existing-VCN Deployment

This folder contains the legacy FortiWeb active/active deployment template that reuses an existing OCI VCN and existing subnets instead of creating a new network.

This pattern is useful when you already have a VCN, internet gateway, and subnet layout that you want the FortiWeb active/active stack to join while retaining your current network design.

## Contents

- [What this template deploys](#what-this-template-deploys)
- [Architecture and interface roles](#architecture-and-interface-roles)
- [Prerequisites](#prerequisites)
- [Deployment methods](#deployment-methods)
- [Repository files](#repository-files)
- [Notes](#notes)

## What this template deploys

The Existing-VCN template deploys the following resources:

- two FortiWeb instances in active/active mode
- a public OCI Network Load Balancer in a designated NLB subnet
- an existing VCN and existing subnet reuse model
- FortiWeb primary interfaces attached to the existing untrusted subnet
- a backend set and listener for active/active traffic distribution
- additional block storage for each FortiWeb node

## Architecture and interface roles

The older Existing-VCN deployment is designed around a shared network environment in which the FortiWeb nodes are added into an existing VCN structure.

| FortiWeb interface | OCI resource | Intended role |
| --- | --- | --- |
| `port1` | primary VNIC in the existing untrusted subnet | Receives traffic from the NLB and can be used for direct management when public IP assignment is enabled |
| `lb` subnet | existing public NLB subnet | Publishes the client-facing application endpoint |
| existing VCN | reused OCI network object | Keeps the deployment aligned with a pre-existing network design |

The main benefit of this template is that it allows you to integrate the FortiWeb active/active pair into an already designed OCI network without creating additional VCN objects.

## Prerequisites

Before deploying this template, confirm that you have:

- a target OCI compartment
- an existing VCN OCID
- the existing VCN CIDR and gateway information
- a chosen availability domain layout for FortiWeb-A and FortiWeb-B
- a valid FortiWeb Marketplace image and license
- the required IAM permissions to create the compute, block volume, and load balancer resources

## Deployment methods

### Deployment with OCI Resource Manager

Use the modern combined Active/Active template in `FortiWeb/Active-Active/terraform` instead of this legacy path. The current stack exposes a single `network_strategy` selector so the same deployment can create a new VCN/subnet layout or reuse an existing one.

The original deployment flow for this variant used OCI Stacks / Resource Manager. For older release bundles, use the region-specific resource manager links that were prepared for the selected FortiWeb version when available.

### Deployment with Terraform CLI

From the `FortiWeb/Active-Active/Existing-VCN` folder:

```bash
terraform init
terraform plan
terraform apply
```

If you use a custom variables file:

```bash
terraform apply -var-file=terraform.tfvars
```

## Repository files

This folder contains the legacy active/active components for the Existing-VCN deployment:

- `terraform/fortiweb-a.tf` — FortiWeb-A instance definition
- `terraform/fortiweb-b.tf` — FortiWeb-B instance definition
- `terraform/network.tf` — shared network integration and NLB resources
- `terraform/image_subscription.tf` — Marketplace subscription logic
- `terraform/variables.tf` — inputs for the deployment
- `terraform/output.tf` — deployment outputs
- `terraform/datasources.tf` — data lookups used during provisioning
- `terraform/customdatafwba.tpl` and `terraform/customdatafwbb.tpl` — instance bootstrap templates

## Notes

- This folder is a legacy deployment path and is best used for existing-network scenarios that require the active/active pair to fit into a current OCI topology.
- The current recommended active/active implementation is the modern stack in `FortiWeb/Active-Active/terraform`.
- For the most complete and up-to-date explanation, see the main active/active deployment guide in `FortiWeb/Active-Active/terraform/README.md`.
