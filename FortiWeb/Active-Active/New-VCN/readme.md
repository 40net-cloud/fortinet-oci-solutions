# FortiWeb Active/Active New-VCN Deployment

This folder contains the legacy FortiWeb active/active deployment template that provisions a new OCI VCN and the networking required for a two-node FortiWeb active/active deployment.

This template is intentionally aligned with the older FortiWeb active/active deployment model and is useful when you want the stack to create its own VCN, internet gateway, subnets, route tables, and public NLB resources.

## Contents

- [What this template deploys](#what-this-template-deploys)
- [Architecture and interface roles](#architecture-and-interface-roles)
- [Prerequisites](#prerequisites)
- [Deployment methods](#deployment-methods)
- [Repository files](#repository-files)
- [Notes](#notes)

## What this template deploys

The New-VCN template creates the following resources:

- one new VCN
- one public NLB subnet
- one untrusted subnet for the FortiWeb primary interfaces
- one trusted subnet for optional FortiWeb-side segmentation
- one Internet Gateway and route tables
- two FortiWeb instances, each deployed with a primary VNIC on the untrusted subnet
- a public OCI Network Load Balancer in front of both FortiWeb appliances
- health checks and backend configuration for active/active traffic distribution

## Architecture and interface roles

The legacy New-VCN design uses a simple active/active front-end model:

| FortiWeb interface | OCI resource | Intended role |
| --- | --- | --- |
| `port1` | primary VNIC in the untrusted subnet | Handles traffic from the NLB and direct management access |
| `port2` | second VNIC in the trusted subnet | Optional service-side or internal segmentation |
| `lb` subnet | public NLB subnet | Publishes the application endpoint |

The main advantage of this pattern is that traffic is distributed across two FortiWeb nodes while the public NLB presents a single client-facing endpoint.

## Prerequisites

Before deploying this template, confirm that you have:

- an OCI tenancy and compartment where the stack will be created
- a supported FortiWeb Marketplace image and valid license
- an OCI region that supports the selected FortiWeb image and compute shape
- the required IAM permissions to create compute, VCN, load balancer, and storage resources

## Deployment methods

### Deployment with OCI Resource Manager

The original deployment flow for this variant used OCI Stacks / Resource Manager. Use the region-specific stack bundles prepared for the selected FortiWeb version when available.

### Deployment with Terraform CLI

From the `FortiWeb/Active-Active/New-VCN` folder:

```bash
terraform init
terraform plan
terraform apply
```

When using a custom input file:

```bash
terraform apply -var-file=terraform.tfvars
```

## Repository files

This folder contains the legacy active/active components for the New-VCN deployment:

- `terraform/fortiweb-a.tf` — FortiWeb-A instance definition
- `terraform/fortiweb-b.tf` — FortiWeb-B instance definition
- `terraform/network.tf` — VCN, subnets, route tables, and NLB resources
- `terraform/image_subscription.tf` — Marketplace subscription logic
- `terraform/variables.tf` — inputs for the deployment
- `terraform/output.tf` — deployment outputs
- `terraform/datasources.tf` — data lookups used during provisioning
- `terraform/customdatafwba.tpl` and `terraform/customdatafwbb.tpl` — instance bootstrap templates

## Notes

- This folder is a legacy deployment path and should be treated as a reference for the older active/active design.
- The current recommended active/active implementation is the modern stack in `FortiWeb/Active-Active/terraform`.
- For the most complete and up-to-date explanation, see the main active/active deployment guide in `FortiWeb/Active-Active/terraform/README.md`.
