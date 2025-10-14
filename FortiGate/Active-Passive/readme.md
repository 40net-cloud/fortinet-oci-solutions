# FortiGate Firewall Active/Passive FGCP Terraform Deployment on Oracle Cloud


This repository provides Terraform code to deploy FortiGate appliances in Oracle Cloud Infrastructure (OCI) using the FGCP architecture.

## Deployment Options

### 1. Deploy Using Oracle Cloud Stack

You can quickly deploy this solution using the Oracle Cloud Stack service:

|FortiGate A/P FGCP Cluster|
|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FortiGate_Active_Passive_Terraform.zip)|

Click the button above to launch the stack in your OCI tenancy. You will be guided through the configuration steps in the Oracle Cloud Console.

### 2. Manual Deployment Using Terraform

#### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- OCI credentials configured ([docs](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformproviderconfiguration.htm))
- Sufficient permissions in your OCI tenancy

#### Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/FortiGate_AP_FGCP_Terraform_v2.0.git
   cd FortiGate_AP_FGCP_Terraform_v2.0
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and update variables:**
   Edit `terraform.tfvars` or set variables as needed.

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the deployment:**
   ```bash
   terraform apply
   ```

6. **Destroy the deployment (when needed):**
   ```bash
   terraform destroy
   ```

## Repository Structure

- `main.tf` – Main Terraform configuration
- `variables.tf` – Input variables
- `outputs.tf` – Output values
- `README.md` – Documentation

## Support

For issues or questions, please open an issue in this repository.

---

© 2025 Your Organization. All rights reserved.
