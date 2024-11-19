## 1. Introduction
This Terraform template deploys a single/standaloneFortiGate Next-Generation Firewall into an existing environment.

## 2. Deployment Overview

The Template deploys following components:
- 2 regional subnets into existing VCN
- 1 FortiGate-VM instance with 2 vNICs
- 2 route tables associated with regional subnets and an NSG

## 3. Deployment Steps


Before starting deployment, **following values are required**:
- Existing VCN OCID
- Existing VCN CIDR block (example: 10.1.0.0/16)
- Existing Internet Gateway OCID (if there is no IGW, it should be created in advance)

One of the two methods can be used to deploy FortiGate Standalone solution in OCI.

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiGate Standalone solution in a specific region. You can select required FortiOS version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### BYOL Images

|v6.4.13|v7.0.15|v7.2.10|v7.4.5|v7.6.0|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v6.4.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.0.15_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.2.10_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.4.5_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.6.0_BYOL.zip)|
---------------------------------------
##### PAYG Images
|v6.4.13|v7.0.14|v7.2.10|v7.4.5|v7.6.0|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v6.4.13_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.0.14_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.2.10_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.4.5_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_ExistingVCN_v7.6.0_PAYG.zip)|

### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiGate > Standalone > Existing-VCN)
3. If you select BYOL deployment, FortiGate license can be activated using web gui.
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
