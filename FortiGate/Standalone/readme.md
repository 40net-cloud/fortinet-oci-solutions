# FortiGate Firewall Standalone Terraform Deployment on Oracle Cloud

This repository contains Terraform code and Oracle Marketplace Resource Manager templates to deploy a standalone FortiGate Firewall on Oracle Cloud Infrastructure (OCI).

## Deployment Options

### 1. Deploy Using Oracle Cloud Resource Manager (Stack)

You can deploy this solution directly from the Oracle Cloud Console using the **Deploy to Oracle Cloud** button below. This will launch the OCI Resource Manager Stack wizard and guide you through the configuration.

|FortiGate Standalone|
|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FortiGate_Standalone_Terraform.zip)|

**Instructions:**
- Click the button above.
- Log in to your Oracle Cloud account.
- Complete the Stack creation wizard, providing required parameters (compartment, network strategy, FortiOS version, CPU type, etc.).
- Review and deploy.

### 2. Deploy Using Pure Terraform

You can also deploy using Terraform CLI:

#### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) v1.0 or later
- Oracle Cloud account and API keys
- Required variables set in `terraform.tfvars` or via environment

#### Steps

```sh
git clone https://github.com/YOUR_REPO.git
cd FortiGate_Standalone_Terraform_v1.0

terraform init
terraform plan
terraform apply
```

**Required Variables:**
- `tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path`, `region`
- `compute_compartment_ocid`, `network_compartment_ocid`
- `license_type` (BYOL or PAYGO)
- `fortios_version` (7.6.3, 7.4.8, 7.2.11, 7.0.17, 6.4.13)
- `cpu_type` (X64 or ARM64)
- Network configuration (VCN, subnets, gateways, etc.)

See [`variables.tf`](/FortiGate/Standalone/terraform/variables.tf) and [`marketplace.yaml`](/FortiGate/Standalone/terraform/marketplace.yaml) for all configurable options.

## Features

- Automated deployment of FortiGate VM with selected FortiOS version and CPU type
- Flexible network strategy: create new or use existing VCN/subnets
- PAYGO and BYOL licensing support
- Customizable compute shapes and OCPUs
- Security groups, route tables, and public/private IP configuration

## File Structure

- [`compute.tf`](/FortiGate/Standalone/terraform/compute.tf): VM and networking resources
- [`network.tf`](/FortiGate/Standalone/terraform/network.tf): VCN, subnets, gateways, route tables, NSGs
- [`variables.tf`](/FortiGate/Standalone/terraform/variables.tf): Input variables
- [`locals.tf`](/FortiGate/Standalone/terraform/locals.tf): Local values and logic
- [`data_sources.tf`](/FortiGate/Standalone/terraform/data_sources.tf): Data sources for OCI resources
- [`image_subscription.tf`](/FortiGate/Standalone/terraform/image_subscription.tf): Marketplace image subscription logic
- [`marketplace.yaml`](/FortiGate/Standalone/terraform/marketplace.yaml): Resource Manager template metadata
- [`final_listings.json`](/FortiGate/Standalone/terraform/final_listings.json): Marketplace image listings

## Support

For issues or feature requests, please open a GitHub issue.

## License

See [`LICENSE`](LICENSE) for details.
