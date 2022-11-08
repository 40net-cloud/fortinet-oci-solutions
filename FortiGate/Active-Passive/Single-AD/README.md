# fortinet-oci-solutions
A set of OCI Terraform Templates for getting you started in Oracle with Fortinet solutions.

# Active/Passive High Available FortiGate pair Regional Subnet.

## Introduction
This Terraform template VERSION.0.12x deploys a High Availability pair of FortiGate Next-Generation Firewallis accompanied by the required infrastructure.
The Template deploys FortiGate A/P Regional Subnet, Single Availability domains with Dual Fault domains.
This also requires an additional OCI configuration for the OCI Fabric connector using IAM roles.
**_Note: Region, Subnet & FG version can be modified_**.

**Port-1**: mgmt (out-of-band management). For API-Call and SDN Connectors.

**Port-2**: WAN (untrust). Towards IGW.

**Port-3**: LAN (Trust). Towards VCN and LPG.

**Port-4**: HeartBeat (HB).Between FG A/P.

<img width="964" alt="Screen Shot 2021-10-05 at 11 16 04 AM" src="https://user-images.githubusercontent.com/64405031/135977322-443625dc-d516-4a06-a431-6cc7ab66948e.png">

<img width="967" alt="Screen Shot 2021-10-05 at 11 08 44 AM" src="https://user-images.githubusercontent.com/64405031/135976457-eebab16f-42c7-4029-bc12-00ec59951f52.png">

## How to deploy

1. Download the 4 files in folder: 00-general.tf, 01-network.tf, 02-fortigate.tf & fgt-userdata.tpl // or from  terminal: **git clone** https://github.com/hkebbi/fortinet-oci-solutions.git
2. Add Two BYOL FG License files name them as: **fgt1.lic**  &  **fgt2.lic**.
3. Compress the folder in a .zip file. 
4. Upload the .zip file in OCI Stack.
5. Fill all required variable fields (except user_ocid, Fingerprint & Private_key_path) as per your network requirements.  
6. Apply the Terraform State. 

**_Note: This will deploy FortiGate-HA by default in "me-jeddah" Region & FG-v.7.0.1.**
However, you can replace the region name in the: "Region" and the "VM_IMAGE_OCID" variable fields with required region name (During Step .5 above):
Example"  "uk-london-1" / "eu-frankfurt-1" / "me-jeddah-1" / "eu-amsterdam-1"

## For new hub VCN Folder:
1. This is used for New VCN, New IGW.
2. This will create New VCN, New IGW, 4 new Subnets, new 4 RTs, new NSG and Two new FG A/P inside VCN with all required config.

## For existing VCN (No_IGW) Folder (VCN and IGW already exist):
1. This is used for existing VCN and existing IGW.
2. Copy/paste VCN-OCID **"Vcn_id"** during terraform deployment on the OCI Stack.
3. This will create 4 new: 4 subnets, Two new RTs (Hb & Trust), new NSG and FG A/P inside existing VCN.
4. Create after deployment Two RTs ( unTrust and Managment) that points to existing IGW (0.0.0.0/0 --> IGW) on OCI RT.

## For existing VCN (with IGW) Folder (VCN already exist, IGW will be created in the script):
1. This is used for existing VCN Only.
2. Copy/paste VCN-OCID **"Vcn_id"** during terraform deployment on the OCI Stack.
3. This will create new: 4 subnets, 4 RTs , IGW, NSG and FG A/P inside existing VCN.


## Additional Configuration:
For the Failover to work automatically: Additional configuration is required to use the IAM role provided by and configurable in the OCI environment for authentication. The IAM role includes permissions that you can give to the instance, so that FortiOS can implicitly access metadata information and communicate to the Fabric connector on its own private internal network without further authentication.

https://docs.fortinet.com/vm/oci/fortigate/6.4/oci-cookbook/6.4.0/562317/configuring-an-oci-fabric-connector-using-iam-roles
