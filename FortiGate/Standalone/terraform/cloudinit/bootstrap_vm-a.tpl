Content-Type: multipart/mixed; boundary="==OCI=="
MIME-Version: 1.0

--==OCI==
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0

config system global
    set hostname "FortiGate-A"
    set admintimeout 60
end

config system interface
    edit port1
        set ip ${mgmt_ip} ${mgmt_ip_mask}
        set allowaccess ping https ssh http fgfm
        set type physical
        set alias mgmt
        set description "mgmt"
        set mtu-override enable
        set mtu 9000
    next
end
config system interface
    edit port2
        set mode static     
        set vdom "root"
        set ip ${trust_ip} ${trust_ip_mask}
        set type physical
        set description "Trust"
        set alias trust
        set mtu-override enable
        set mtu 9000
        set secondary-IP enable
    next
end

%{ if tonumber(split(".", fortios_version)[0]) < 7 || (tonumber(split(".", fortios_version)[0]) == 7 && tonumber(split(".", fortios_version)[1]) <= 2) }
config system sdn-connector
    edit "oci-sdn"
        set type oci
        set ha-status enable
        set tenant-id ${tenancy_ocid}
        set compartment-id ${compartment_ocid}
    next
end
%{ else }
config system sdn-connector
    edit "oci-sdn"
        set type oci
        set ha-status enable
        set tenant-id ${tenancy_ocid}
        config compartment-list
            edit ${compartment_ocid}
            next
        end
end
%{ endif }
config router static
    edit 1        
        set gateway ${mgmt_subnet_gw}
        set device port1
    next
    edit 2
        set dst ${vcn_cidr}
        set gateway ${trust_subnet_gw}
        set device port2
    next
end
--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

--==OCI==--
