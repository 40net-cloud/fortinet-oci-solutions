## 1. Introduction
This Terraform template deploys a Active/Active High Availability pair of FortiWeb accompanied by the required infrastructure.

## 2. Deployment Overview

The Template deploys following components:
- A **new** Virtual Cloud Network (VCN) with 3 regional subnets (network load balancer, untrust and trust)
- Flexible Network Load Balancer (NLB) in specific network load balancer subnet
- Backend Set with health check over TCP/8443 (_can be modified later_)
- NLB backends pointing FortiWeb port1 IPs
- NLB listener with ANY protocol setting (_can be modified later_)
- 2 FortiWeb-VM instances with 2 vNICs, each in **selected** AD, also in **separate Fault Domain (FD)**
- 2 route tables associated with regional subnets and an NSG

### 2.1 Deployment Options

Depending on selected Oracle Cloud region, 1 or more AD (availability domain) can be selected during deployment as follows.

- **Dual-AD**: Define different AD variable (e.g. "1" for ad_a and "2" for ad_b)
- **Single-AD**: Define same AD variable (e.g. "1" for ad_a and "1" for ad_b)

## 3. Deployment Steps

One of the two methods below can be used to deploy FortiWeb A/A solution in OCI.

### 3.1 Quick Deployment Using OCI Stacks service

Following links are prepared to deploy FortiWeb A/A cluster in a specific region. You can select required FortiWeb version to proceed. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

##### OCI public regions - BYOL Images (requires FortiWeb license files)

|v6.0.2|v6.1.1|v6.3.4|v7.0.4|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_NewVCN_v6.0.2_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_NewVCN_v6.1.1_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_NewVCN_v6.3.4_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_NewVCN_v7.0.4_BYOL.zip)

---------------------------------------
##### OCI DRCC Oman region - BYOL Images (requires FortiWeb license files)

|v6.0.2|v6.1.1|v6.3.4|v7.0.4|
|:-:|:-:|:-:|:-:|
|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_DRCC_NewVCN_v6.0.2_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_DRCC_NewVCN_v6.1.1_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_DRCC_NewVCN_v6.3.4_BYOL.zip)|[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://oc9.cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/fwbactiveactive/FWB_A-A_DRCC_NewVCN_v7.0.4_BYOL.zip)

### 3.2. Manual Deployment Using Terraform CLI

Prerequisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files. (path: fortinet-oci-solutions > FortiWeb > Active-Active > New-VCN)
3. Edit _terraform.tfvars_ file with required fields (tenancy_ocid, compartment_ocid, region etc.)
4. Initialize the Terraform using following command
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
