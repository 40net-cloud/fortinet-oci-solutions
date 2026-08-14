# FortiWeb Active/Active OCI Marketplace stack

This directory contains one OCI Resource Manager/Marketplace stack for a pair
of FortiWeb appliances in active/active high-volume mode behind a public OCI
Network Load Balancer.

## Network choices

- **Create New VCN** creates a VCN, Internet Gateway, and three regional
  subnets for the NLB, FortiWeb port1, and FortiWeb port2.
- **Use Existing VCN and Create New Subnets** reuses a selected VCN and an
  existing Internet Gateway but creates the three FortiWeb subnets, route
  tables, and security lists.

The second option intentionally does not reuse existing subnets.

## Marketplace inventory

`final_listings.json` maps the GUI's license and version selections to a
Marketplace listing and resource version. Terraform then resolves that package
to the correct image OCID for the deployment region. The version and license
enums in `marketplace.yaml` must remain synchronized with the JSON inventory.

## Validate locally

```shell
terraform fmt -recursive -check .
terraform init -backend=false
terraform validate
```

For a local plan, provide all required variables through a `.tfvars` file or
`TF_VAR_` environment variables. OCI Resource Manager supplies `tenancy_ocid`,
`compartment_ocid`, and `region` through its deployment workflow.

## Package for Resource Manager

Run this command from this directory so the Terraform and YAML files are at the
root of the ZIP:

```shell
zip -r fortiweb-active-active.zip . \
  -x '.terraform/*' '*.tfstate*' '*.tfplan' 'fortiweb-active-active.zip'
```

Do not package a `.terraform` directory or Terraform state files.
