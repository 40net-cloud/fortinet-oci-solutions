# Active/Passive High Available FortiGate pair Regional Subnet with New VCN & Dual FD. 

## Introduction

This Terraform template deploys a High Availability pair of FortiGate Next-Generation Firewallis accompanied by the required infrastructure.
The Template deploys new OCI VCN, with FGv6.4.2 in A/P Regional Subnet, Single Availability domains with Dual Fault domains.

**_Note: Region, Subnet & FG version can be modified_**.


## How to deploy

1. Download the 4 files in folder: 00-general.tf, 01-network.tf, 02-fortigate.tf & fgt-userdata.tpl 1

2. Add Two BYOL FG License files name them as: fgt1.lic  &  fgt2.lic 2
3. Compress the folder in a .zip file 3 
4. Upload the .zip file in OCI Stack 4
5. Fill all the variable fields (all are mandatory) as per your requirements 5
6. Apply the Terraform State 6

**_Note: This will deploy FortiGate by default in "eu-frankfurt-1" & FG in v.6.4.2.**
However, you can change the region name in the: "Region" and the and "VM_IMAGE_OCID" variable fields with required region:
Example"  "uk-london-1" / "eu-frankfurt-1" / "me-jeddah-1" / "eu-amsterdam-1"


## Design


## Requirements and limitations
