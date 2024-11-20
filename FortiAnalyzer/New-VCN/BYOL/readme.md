## 1. Introduction
This Terraform template facilitates the deployment of a standalone FortiAnalyzer instance along with the necessary infrastructure on Oracle Cloud Infrastructure (OCI).

## 2. Deployment Overview

The template provisions the following components:
- A **new** Virtual Cloud Network (VCN) with a single regional subnet (untrust).
- A Standalone FortiAnalyzer-VM instance with one vNIC.
- A route table associated with the regional subnet and a Security List.

## 3. Deployment Steps

You can deploy the FortiAnalyzer standalone solution on OCI using one of two methods:

### 3.1 Quick Deployment Using OCI Stacks service

Preconfigured links for quick deployment are provided below. Select the required FortiAnalyzer OS version and follow the deployment steps. Ensure you are logged into the OCI Dashboard before proceeding.

##### BYOL Images (Bring Your Own License)

|v6.4.15|v7.0.13|v7.2.8|v7.4.5|v7.6.1|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_NewVCN_v6.4.15_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_NewVCN_v7.0.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_NewVCN_v7.2.8_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_NewVCN_v7.4.5_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_NewVCN_v7.6.1_BYOL.zip)|

<!---
##### OCI DRCC Oman region - BYOL Images (requires FortiAnalyzer license files)

|v6.4.11|v7.0.7|v7.2.3|v7.4.0|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_NewVCN_v6.4.11_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_NewVCN_v7.0.7_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_NewVCN_v7.2.3_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fazstandalone/FAZ_Standalone_DRCC_NewVCN_v7.4.0_BYOL.zip)
--->
### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Clone the Repository: Download the required files or clone the repository using the following command:
```
git clone https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to the Terraform Directory: Access the folder containing the Terraform files. (path: fortinet-oci-solutions > FortiAnalyzer > New-VCN > BYOL)
3. Configure FortiAnalyzer License: The license can be activated via the FortiAnalyzer web GUI after deployment.
4. Edit Variables: Open the terraform.tfvars file and populate the required fields such as tenancy_ocid, compartment_ocid, region etc.
5. Initialize Terraform: Run the following command to initialize Terraform and download necessary providers:
```
terraform init
```
6. Validate Configuration: Run a plan to ensure there are no errors or warnings:
```
terraform plan
```
7. Deploy the Resources: Apply the Terraform configuration to deploy the FortiAnalyzer:
```
terraform apply
```
