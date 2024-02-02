## 1. Introduction
This Terraform template deploys a High Availability pair of FortiGate Next-Generation Firewalls into an existing Single-AD environment.

## 2. Deployment Overview

The Template deploys following components:
- 4 regional subnets into existing VCN
- 2 FortiGate-VM instances with 4 vNICs, each in **selected** AD, also in **separate Fault Domain (FD)**
- 4 route tables associated with regional subnets and an NSG
- Required FortiGate configuration to activate A/P cluster using cloud-init (**read official note below**)

### 2.1 Deployment Options

Depending on selected region, 1 or more AD (availability domain) can be selected during deployment as follows.

- **Dual-AD**: Define different AD variable (e.g. "1" for ad_a and "2" for ad_b)
- **Single-AD**: Define same AD variable (e.g. "1" for ad_a and "1" for ad_b)

## 3. Deployment Steps

Before starting deployment, **following values are required**:
- Availability Domain ID (can be picked as 1, 2 or 3)
- Existing VCN OCID
- Existing VCN CIDR block (example: 10.0.0.0/16)
- Existing Internet Gateway OCID (if there is no IGW, it should be created in advance)

One of the two methods can be used to deploy FortiGate A/P solution in OCI.

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiGate A/P cluster in Dual-AD in a specific region. You can select required FortiOS version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### BYOL Images (requires FortiGate license files)

|v6.4.13|v7.0.12|v7.2.5|v7.4.0|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v6.4.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.0.12_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.2.5_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.4.0_BYOL.zip)

---------------------------------------
##### PAYG Images
|v6.4.10|v6.4.11|v7.0.9|v7.2.4|v7.4.2|
|:-:|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v6.4.10_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v6.4.11_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.0.9_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.2.4_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_ExistingVCN_v7.4.2_PAYG.zip)

---------------------------------------
##### OCI DRCC Oman region - BYOL Images (requires FortiGate license files)

|v6.4.13|v7.0.12|v7.2.5|v7.4.0|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_DRCC_ExistingVCN_v6.4.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_DRCC_ExistingVCN_v7.0.13_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_DRCC_ExistingVCN_v7.2.5_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fgtactivepassive/FGT_A-P_DRCC_ExistingVCN_v7.4.0_BYOL.zip)

### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiGate > Active-Passive > Existing-VCN)
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


