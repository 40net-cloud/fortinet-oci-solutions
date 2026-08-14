# FortiAnalyzer Standalone Terraform Deployment for Oracle Cloud

Deploy one standalone FortiAnalyzer-VM on Oracle Cloud Infrastructure (OCI) with Terraform and an OCI Marketplace image.

This template supports deployment through OCI Resource Manager or the Terraform CLI. It is a single-instance, Bring Your Own License (BYOL) deployment; it does not create a FortiAnalyzer HA cluster.

> [!WARNING]
> Review the security limitations below before deploying. The current Terraform assigns a public IPv4 address to the FortiAnalyzer management interface and creates an allow-all ingress security list when it creates a VCN. The `nsg_whitelist_ip` input is not currently enforced, and the created Network Security Group (NSG) is not attached to the instance. Do not use the default networking configuration for production until these Terraform issues are corrected.


## Deployment Options

### 1. "Deploy to Oracle Cloud" Button (Recommended)

- **One-click deployment via OCI Resource Manager Stacks.**

**How to use:**
- Click the "Deploy to Oracle Cloud" button for FortiAnalyzer.
- You will be redirected to OCI Resource Manager Stacks.
- Launch the stack to deploy FortiAnalyzer.

|FortiAnalyzer Standalone|
|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FortiAnalyzer_Standalone_Terraform.zip)|

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
4. Access the public IP output for FortiAnalyzer.

## File Overview

- [`marketplace.yaml`](/FortiAnalyzer/terraform/marketplace.yaml): OCI Resource Manager schema for UI-driven deployments.
- [`provider.tf`](/FortiAnalyzer/terraform/provider.tf): OCI provider configuration.
- [`variables.tf`](/FortiAnalyzer/terraform/variables.tf): All input variables.
- [`locals.tf`](/FortiAnalyzer/terraform/locals.tf): Dynamic logic and Marketplace image selection.
- [`compute.tf`](/FortiAnalyzer/terraform/compute.tf): VM and block volume resources.
- [`network.tf`](/FortiAnalyzer/terraform/network.tf): VCN, subnets, gateways, route tables.
- [`data_sources.tf`](/FortiAnalyzer/terraform/data_sources.tf): Data sources for compartments, ADs, security lists.
- [`image_subscription.tf`](/FortiAnalyzer/terraform/image_subscription.tf): Marketplace image agreement and subscription.
- [`output.tf`](/FortiAnalyzer/terraform/output.tf): Outputs (e.g., public IP).
- [`final_listings.json`](/FortiAnalyzer/terraform/final_listings.json): Marketplace image metadata.
- [`build-orm/install.tf`](/FortiAnalyzer/terraform/build-orm/install.tf): Helper for packaging the deployment for OCI Resource Manager.

## Outputs

- `fortianalyzer_vm_a_public_ip`: Public IP address of the deployed VM.

## Support

For issues or questions, open an issue in this repository.

---
