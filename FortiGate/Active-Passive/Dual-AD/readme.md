# FortiGate Active/Passive High Available Dual-AD Deployment

## 1. Introduction
This Terraform template deploys a High Availability pair of FortiGate Next-Generation Firewalls accompanied by the required infrastructure.

## 2. Deployment Options

One of the options below can be picked to deploy FortiGate A/P HA solution in OCI platform:
- [Existing VCN](https://github.com/40net-cloud/fortinet-oci-solutions/tree/main/FortiGate/Active-Passive/Dual-AD/Existing-VCN) (VCN and IGW should be created already)
- [New VCN](https://github.com/40net-cloud/fortinet-oci-solutions/tree/main/FortiGate/Active-Passive/Dual-AD/New-VCN) (template creates all required components including a new VCN)

An additional OCI configuration is required for the OCI SDN-Connector using IAM roles (see documentation [configuring SDN connector](https://docs.fortinet.com/document/fortigate-public-cloud/7.2.0/oci-administration-guide/442167/sdn-connector-integration-with-oci))</br>

**_Note_**: Variables (region, CIDRs) can be modified.

FortiGate-VMs will be provisioned with following vNICs:</br>
**port1**: Management (used for SDN connector API call)</br>
**port2**: External (untrust, Internet facing)</br>
**port3**: Internal (trust, internal communication towards LPG/DRG to other VCNs)</br>
**port4**: HeartBeat (hb, used for cluster sync)</br>

## 3. Topology Diagram

Diagram below is showing logical placement of FortiGate-VMs in VCN. Same diagram applies both deployment options. 

<img width="665" alt="Screen Shot 2021-10-05 at 12 20 17 PM" src="https://user-images.githubusercontent.com/64405031/135986810-68a958e5-6817-4c79-93f2-6566d34dc5a0.png">

<img width="664" alt="Screen Shot 2021-10-05 at 12 20 08 PM" src="https://user-images.githubusercontent.com/64405031/135986825-522a699c-2eec-4fe7-8f20-24f48c5a5ccd.png">

## 4. Deployment Steps

One of the two methods can be used to deploy FortiGate A/P Dual-AD solution in OCI.

### 4.1 Quick Deployment Using OCI Stacks service

You will find multiple links per available FortiOS version separately. You can select required FortiOS version to start deployment. User should be already logged into OCI Dashboard.

### 4.2 Manual Deployment Using Terraform CLI

Pre-requisite to proceed: Terraform-CLI should be downloaded already. 

1. Download the files in a local folder or clone the repository using command below:</br>
```
https://github.com/40net-cloud/fortinet-oci-solutions.git
```
2. Navigate to required folder that includes "_.tf_" files.
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

## 5. Additional Configuration:
For the Failover to work automatically: Additional configuration is required to use the IAM role provided by and configurable in the OCI environment for authentication. The IAM role includes permissions that you can give to the instance, so that FortiOS can implicitly access metadata information and communicate to the Fabric connector on its own private internal network without further authentication.

[Configuring SDN Connector](https://docs.fortinet.com/vm/oci/fortigate/6.4/oci-cookbook/6.4.0/562317/configuring-an-oci-fabric-connector-using-iam-roles)
