This README.md serves as a comprehensive guide for deploying a standalone FortiAnalyzer on Oracle Cloud Infrastructure (OCI) using Terraform. The guide outlines deployment steps, prerequisites, and deployment methods.

## 1. Introduction
This Terraform template simplifies the deployment of a standalone FortiAnalyzer into an existing OCI environment. It provides both automated and manual methods for deployment.

## 2. Deployment Overview

The template deploys the following components:
- **Regional Subnet:** One subnet in the existing VCN.
- **FortiAnalyzer Instance:** A FortiAnalyzer-VM instance with a single vNIC.
- **Route Table:** Includes routing configurations and is associated with the regional subnet and an NSG (Network Security Group).

## 3. Deployment Methods

Before starting deployment, **following values are required**. All other settings can be modified.
- Existing VCN OCID
- Existing VCN CIDR block (example: 10.1.0.0/16)
- Existing Internet Gateway OCID (if there is no IGW, it should be created in advance)

Two methods are available for deploying the standalone FortiAnalyzer:

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiAnalyzer Standalone solution in a specific region. You can select required FortiAnalyzer OS version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### BYOL Images

|v6.4.15|v7.0.13|v7.2.8|v7.4.5|v7.6.1|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_ExistingVCN_v6.4.15_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_ExistingVCN_v7.0.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_ExistingVCN_v7.2.8_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_ExistingVCN_v7.4.5_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_ExistingVCN_v7.6.1_BYOL.zip)|
<!---
##### OCI DRCC Oman region - BYOL Images (requires FortiAnalyzer license files)

|v6.4.11|v7.0.7|v7.2.3|v7.4.0|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_ExistingVCN_v6.4.11_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_ExistingVCN_v7.0.7_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_ExistingVCN_v7.2.3_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_ExistingVCN_v7.4.0_BYOL.zip)
--->
### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiAnalyzer  > Existing-VCN > BYOL)
3. FortiAnalyzer license can be activated using web gui.
4. Edit _terraform.tfvars_ file with required fields (tenancy_ocid, compartment_ocid, region etc.)
5. Initialize the Terraform using following command
```
terraform init
```
6. Use plan option to double check if there is no error/warning in the code.
```
terraform plan
```
7. Apply Terraform state.
```
terraform apply
```
