- Select [**New-VCN**](FortiGate/Active-Passive/New-VCN) for fresh deployment into new infrastructure. 
- Select [**Existing-VCN**](FortiGate/Active-Passive/Existing-VCN) for deploying into existing infrastructure. 

**Official Note**: After deployment, FortiGate-VM instances may not get the proper configurations during the initial bootstrap configuration. User may need to do a manual factoryreset on the FortiGate-VMs in order to get proper configurations. To do factoryreset in FortiGate, user can login to the units via Console, and execute following command:

```
exec factoryreset
```
