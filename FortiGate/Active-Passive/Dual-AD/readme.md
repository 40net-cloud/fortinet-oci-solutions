# Active/Passive High Available FortiGate pair Regional Subnet

## Introduction
This Terraform template v0.12x deploys a High Availability pair of FortiGate Next-Generation Firewalls accompanied by the required infrastructure.

## Deployment Overview

The Template deploys following components:
- A **new** Virtual Cloud Network (VCN) with 4 subnets (untrust, trust, hb and mgmt)
- 2 FortiGate-VM instances with 4 vNICs, each in different AD
- Required FortiGate configuration to activate A/P cluster using cloud-init (**read note below**)

An additional OCI configuration for the OCI Fabric connector using IAM roles.</br>
**_Note_**: Region, Subnet & FG version can be modified.

**port1**: Management (used for SDN connector API call)</br>
**port2**: External (untrust, Internet facing)</br>
**port3**: Internal (trust, internal communication towards LPG/DRG to other VCNs)</br>
**port4**: HeartBeat (hb, used for cluster sync)</br>

<img width="665" alt="Screen Shot 2021-10-05 at 12 20 17 PM" src="https://user-images.githubusercontent.com/64405031/135986810-68a958e5-6817-4c79-93f2-6566d34dc5a0.png">

<img width="664" alt="Screen Shot 2021-10-05 at 12 20 08 PM" src="https://user-images.githubusercontent.com/64405031/135986825-522a699c-2eec-4fe7-8f20-24f48c5a5ccd.png">

## How to deploy

1. Download the files in folder: or from  terminal: **git clone** https://github.com/hkebbi/fortinet-oci-solutions.git
2. Add Two BYOL FG License files name them as: **FGT-A-license-filename.lic** & **FGT-B-license-filename.lic**
3. In the terraform.tvars file fill: "tenancy_ocid", "compartment_ocid", & region.
4. Compress the folder in a .zip file. 
5. Upload the .zip file in OCI Stack.
6. Fill all required variable fields (except user_ocid, Fingerprint & Private_key_path) as per your network requirements.  
7. Apply the Terraform State. 

**_Note: This will deploy FortiGate-HA by default in "eu-frankfurt-1" Region & FG-v.7.0.1.**
However, you can replace the region name in the: "Region" and the "VM_IMAGE_OCID" variable fields with required region name (During Step .5 above):
Example"  "uk-london-1" / "eu-frankfurt-1" / "me-jeddah-1" / "eu-amsterdam-1"

## For new hub VCN Folder:
1. This is used for New VCN, New IGW.
2. This will create New VCN, New IGW, 4 new Subnets, new 4 RTs, new NSG and Two new FG A/P inside VCN with all required config.

## Additional Configuration:
For the Failover to work automatically: Additional configuration is required to use the IAM role provided by and configurable in the OCI environment for authentication. The IAM role includes permissions that you can give to the instance, so that FortiOS can implicitly access metadata information and communicate to the Fabric connector on its own private internal network without further authentication.

https://docs.fortinet.com/vm/oci/fortigate/6.4/oci-cookbook/6.4.0/562317/configuring-an-oci-fabric-connector-using-iam-roles

