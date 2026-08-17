# FortiADC standalone deployment on OCI

This Terraform stack deploys a single Fortinet FortiADC virtual appliance from Oracle Cloud Marketplace. It follows the two-interface standalone pattern used by the FortiGate standalone template:

- `port1` is the frontend and management interface. It can receive an ephemeral public IP.
- `port2` is the private backend interface used to reach application servers.

The stack is compatible with OCI Resource Manager and standard Terraform workflows.

## Supported software and licensing

Only Bring Your Own License (BYOL) is supported. Have a valid FortiADC-VM license ready before deployment.

Supported Marketplace package versions:

- 6.1.1
- 6.0.1
- 5.4

## Supported shapes

- `VM.Standard1.1`
- `VM.Standard1.2`
- `VM.Standard1.4`
- `VM.Standard1.8`
- `VM.Standard1.16`
- `VM.Standard2.1`
- `VM.Standard2.2`

Shape availability and Marketplace-image compatibility vary by OCI region and availability domain. The stack checks the selected image's regional compatible-shape list before creating the instance.

## Resources created

The stack always creates:

- One FortiADC compute instance
- One secondary VNIC for `port2`
- A frontend network security group
- A backend network security group
- A FortiADC Marketplace agreement and, by default, a subscription

With **Create New VCN and Subnets**, it also creates:

- One VCN
- One public frontend subnet for `port1`
- One private backend subnet for `port2`
- One internet gateway
- Separate frontend and backend route tables

With **Use Existing VCN and Subnets**, it uses the supplied VCN and subnet OCIDs and does not change their route tables or security lists.

OCI evaluates subnet security lists in addition to the NSGs created by this stack. Review existing subnet security lists because permissive rules there can broaden access beyond these NSGs.

## Network access

The frontend NSG permits:

- HTTPS (`443`) and SSH (`22`) from `management_cidr`
- TCP ports `client_port_min` through `client_port_max` from `client_ingress_cidr`
- All outbound traffic

The backend NSG permits all traffic from `backend_subnet_cidr` and all outbound traffic. Adjust these rules to match your security requirements.

The default `management_cidr` is `0.0.0.0/0` for initial usability. For production, set it to a trusted administrator address such as `203.0.113.10/32`.

## Deploy with OCI Resource Manager

1. Create a ZIP archive containing the files in this `terraform` directory. Keep `marketplace.yaml` at the root of the archive.
2. In the OCI Console, open **Developer Services > Resource Manager > Stacks**.
3. Create a stack from the ZIP file.
4. Enter the compute, network, and access values.
5. Run a plan and review the proposed resources.
6. Apply the stack.

The stack accepts the Oracle Marketplace agreement when `mp_subscription_enabled` is `true`. By applying it, you agree to the Marketplace listing terms.

## Deploy with Terraform CLI

Requirements:

- Terraform 1.4 or newer
- OCI provider authentication configured locally
- Permission to manage Compute, Networking, and App Catalog subscriptions in the target compartment

Copy the example variables file and replace its placeholder OCIDs:

```shell
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

For an existing network, set:

```hcl
network_strategy  = "Use Existing VCN and Subnets"
vcn_id            = "ocid1.vcn.oc1..."
frontend_subnet_id = "ocid1.subnet.oc1..."
backend_subnet_id  = "ocid1.subnet.oc1..."
```

The frontend subnet must permit public IP assignment if `assign_public_ip` is `true`. Its route table must provide the required path to an internet gateway. The backend subnet should have routes to the application servers that FortiADC will serve.

## First login and licensing

After deployment, use the `management_url` output. The initial credentials are:

- Username: `admin`
- Password: the FortiADC instance OCID, returned as the sensitive `initial_password` output

Retrieve the sensitive output from Terraform CLI with:

```shell
terraform output -raw initial_password
```

Change the password immediately, then upload and activate your FortiADC BYOL license through the FortiADC interface. Licensing can trigger a reboot.

The bootstrap configuration leaves `port1` on DHCP so it retains OCI's primary-VNIC address and default gateway. It assigns the configured static `backend_private_ip` to `port2` and enables ping on that interface.

## Outputs

- `management_url`
- `management_public_ip`
- `frontend_private_ip`
- `backend_private_ip`
- `instance_id`
- `initial_password` (sensitive)
- `selected_marketplace_image_id`

## Notes

- This is a standalone deployment and does not configure FortiADC high availability.
- Application pools, real servers, health checks, and virtual servers are configured after deployment in FortiADC.
- The instance uses paravirtualized networking, as recommended by the current FortiADC OCI deployment guide.
- OCI reserves the first two addresses and the last address of every subnet. The template rejects those addresses for FortiADC interfaces.

## References

- [FortiADC OCI deployment guide](https://docs.fortinet.com/document/fortiadc-public-cloud/latest/oracle-cloud-infrastructure-deployment-guide)
- [OCI Marketplace subscriptions in Terraform](https://docs.oracle.com/en-us/iaas/Content/Marketplace/Tasks/subscribe-terraform-configurations.htm)
- [FortiGate standalone reference template](https://github.com/40net-cloud/fortinet-oci-solutions/tree/main/FortiGate/Standalone)
