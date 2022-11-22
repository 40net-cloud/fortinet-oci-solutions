## 1. Introduction
This Terraform template deploys a High Availability pair of FortiGate Next-Generation Firewalls accompanied by the required infrastructure.

## 2. Deployment Overview

The Template deploys following components:
- A **new** Virtual Cloud Network (VCN) with 4 regional subnets (untrust, trust, hb and mgmt)
- 2 FortiGate-VM instances with 4 vNICs, each in different AD
- 4 route tables associated with regional subnets and an NSG
- Required FortiGate configuration to activate A/P cluster using cloud-init (**read official note below**)

## 3. Deployment Steps

One of the two methods can be used to deploy FortiGate A/P solution in OCI.

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiGate A/P cluster in Dual-AD in a specific region. You can select required FortiOS version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### BYOL Images (requires FortiGate license files)

|v6.4.10|v6.4.11|v7.0.8|v7.2.3
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.10_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.11_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.0.8_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.2.3_BYOL.zip)

---------------------------------------
##### PAYG Images
|v6.4.10|v6.4.11|v7.0.8|v7.2.3
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.10_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.11_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.0.8_PAYG.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.2.3_PAYG.zip)

### 3.2. Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiGate > Active-Passive > Dual-AD > New-VCN)
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
