## 1. Introduction
This Terraform template deploys a single/standaloneFortiGate Next-Generation Firewall accompanied by the required infrastructure.

## 2. Deployment Overview

The Template deploys following components:
- A **new** Virtual Cloud Network (VCN) with 2 regional subnets (untrust and trust)
- 1 FortiGate-VM instances with 2 vNICs
- 2 route tables associated with regional subnets and an NSG

## 3. Deployment Steps

One of the two methods can be used to deploy FortiGate Standalone solution in OCI.

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiGate Standalone solution in a specific region. You can select required FortiOS version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### BYOL Images

|v6.4.13|v7.0.17|v7.2.11|v7.4.8|v7.6.3|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v6.4.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.0.17_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.2.11_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.4.8_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.6.3_BYOL.zip)|
---------------------------------------
##### PAYG Images
|v6.4.13|v7.0.17|v7.2.11|v7.4.8|v7.6.3|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v6.4.13_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.0.17_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.2.11_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.4.8_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtstandalone/FGT_Standalone_NewVCN_v7.6.3_PAYG.zip)|

### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiGate > Standalone > New-VCN)
3. If you select BYOL deployment, add 2 FortiGate license files to **_license/_** folder and rename them as: FGT-A-license-filename.lic and FGT-B-license-filename.lic (PAYG deployment does NOT require license files, so related _.tf_ files and bootstrap script should be updated accordingly)
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

**Official Note**: After deployment, FortiGate-VM instances may not get the proper configurations during the initial bootstrap configuration. User may need to do a manual factoryreset on the FortiGate-VMs in order to get proper configurations. To do factoryreset in FortiGate, user can login to the units via Console, and execute following command:

```
exec factoryreset
```

