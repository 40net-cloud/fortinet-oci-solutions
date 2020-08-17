# Active/Passive High Available FortiGate pair Regional Subnet with New VCN, Single AD & Dual FD. 

## Introduction

This Terraform template VERSION.0.12x deploys a High Availability pair of FortiGate Next-Generation Firewallis accompanied by the required infrastructure.
The Template deploys new OCI VCN, with FGv6.4.2 in A/P Regional Subnet, Single Availability domains with Dual Fault domains.
This also requires an additional OCI configuration for the OCI Fabric connector using IAM roles.

**_Note: Region, Subnet & FG version can be modified_**.

## Design

Refer to: https://docs.fortinet.com/vm/oci/fortigate/6.4/oci-cookbook/6.4.0/427168/deploying-fortigate-vm-ha-on-oci-within-one-ad 

![GitHub Logo](https://user-images.githubusercontent.com/64405031/90371151-91372480-e07f-11ea-915e-9abc0a595418.png)

## How to deploy

1. Download the 4 files in folder: 00-general.tf, 01-network.tf, 02-fortigate.tf & fgt-userdata.tpl  // find the file in question, click on it, and then click “View Raw”, “Download...

2. Add Two BYOL FG License files name them as: fgt1.lic  &  fgt2.lic
3. Compress the folder in a .zip file 
4. Upload the .zip file in OCI Stack
5. Fill all the variable fields (all are mandatory) as per your requirements 
6. Apply the Terraform State 

**_Note: This will deploy FortiGate by default in "eu-frankfurt-1" & FG in v.6.4.2_.**
However, you can change the region name in the: "Region" and the "VM_IMAGE_OCID" variable fields with required region:
Example"  "uk-london-1" / "eu-frankfurt-1" / "me-jeddah-1" / "eu-amsterdam-1"

## Requirements and limitations

For the Failover to work automatically: Additional configuration is required to use the IAM role provided by and configurable in the OCI environment for authentication. The IAM role includes permissions that you can give to the instance, so that FortiOS can implicitly access metadata information and communicate to the Fabric connector on its own private internal network without further authentication.

https://docs.fortinet.com/vm/oci/fortigate/6.4/oci-cookbook/6.4.0/562317/configuring-an-oci-fabric-connector-using-iam-roles
