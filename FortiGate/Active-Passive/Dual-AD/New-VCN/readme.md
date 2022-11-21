**Official Note**: After deployment, FortiGate-VM instances may not get the proper configurations during the initial bootstrap configuration. User may need to do a manual factoryreset on the FortiGate-VMs in order to get proper configurations. To do factoryreset in FortiGate, user can login to the units via Console, and execute following command:

```
exec factoryreset
```
## Deployment

Following links are prepared to deploy FortiGate A/P cluster in Dual-AD. Since buttons will be re-directing to use OCI Stacks service, user should be already logged into OCI Dashboard.

### Quick deployment using OCI Stacks service ###

#### BYOL Images (requires FortiGate license files)

##### v6.4.10 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.10_BYOL.zip)
##### v6.4.11 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.11_BYOL.zip)
##### v7.0.8 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.0.8_BYOL.zip)
##### v7.2.3 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.2.3_BYOL.zip)
---------------------------------------
#### PAYG Images
##### v6.4.10 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.10_PAYG.zip)
##### v6.4.11 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v6.4.11_PAYG.zip)
##### v7.0.8 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.0.8_PAYG.zip)
##### v7.2.3 [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/40net-cloud/fortinet-oci-solutions/releases/download/activepassivedualad/FGT_A-P_Dual-AD_NewVCN_v7.2.3_PAYG.zip)
