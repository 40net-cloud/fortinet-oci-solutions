# FortiManager Standalone Terraform Deployment for Oracle Cloud

This package enables automated deployment of FortiManager Standalone VM(s) on Oracle Cloud Infrastructure (OCI) using Marketplace images.

## Deployment Options

### 1. "Deploy to Oracle Cloud" Button (Recommended)

- **One-click deployment via OCI Resource Manager Stacks.**

**How to use:**
- Click the "Deploy to Oracle Cloud" button for FortiManager.
- You will be redirected to OCI Resource Manager Stacks.
- Launch the stack to deploy FortiManager.

|FortiManager Standalone|
|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fmgstandalone/FortiManager_Standalone_Terraform_v1.0.zip)|

### 2. Terraform CLI

- **Manual deployment using Terraform CLI.**
- Full control over variables and customization.

**Steps:**
1. Clone this repository.
2. Configure variables in `terraform.tfvars` or via CLI.
3. Run:
   ```sh
   terraform init
   terraform plan
   terraform apply
   ```
4. Access the public IP output for FortiManager.

## File Overview

- [`marketplace.yaml`](marketplace.yaml): OCI Resource Manager schema for UI-driven deployments.
- [`provider.tf`](provider.tf): OCI provider configuration.
- [`variables.tf`](variables.tf): All input variables.
- [`locals.tf`](locals.tf): Dynamic logic and Marketplace image selection.
- [`compute.tf`](compute.tf): VM and block volume resources.
- [`network.tf`](network.tf): VCN, subnets, gateways, route tables.
- [`data_sources.tf`](data_sources.tf): Data sources for compartments, ADs, security lists.
- [`image_subscription.tf`](image_subscription.tf): Marketplace image agreement and subscription.
- [`output.tf`](output.tf): Outputs (e.g., public IP).
- [`final_listings.json`](final_listings.json): Marketplace image metadata.
- [`build-orm/install.tf`](build-orm/install.tf): Helper for packaging the deployment for OCI Resource Manager.

## Outputs

- `fortimanager_vm_a_public_ip`: Public IP address of the deployed VM.

## Support

For issues or questions, open an issue in this repository.

---
