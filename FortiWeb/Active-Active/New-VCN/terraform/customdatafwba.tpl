Content-Type: multipart/mixed; boundary="==OCI=="
MIME-Version: 1.0

--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname ${fwba_vm_name}
end
config system interface
  edit port1
    set type physical
    set allowaccess ping ssh snmp http https FWB-manager
    set mode dhcp
  next
end
config system interface
  edit port2
    set type physical
    set ip ${fwba_ipaddress_port2} ${trust_mask}
    set allowaccess ping ssh http https
  next
end
config router static
  edit 1
    set device port1
    set gateway ${untrusted_gateway_ip}
  next
end
config system ha
    set mode active-active-high-volume
  set group-id 1
  set group-name fwbaa
  set priority 1
  set override enable
  set tunnel-local ${fwba_ipaddress_port2}
  set tunnel-peer ${fwbb_ipaddress_port2}
  set monitor port1 port2
  
--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

--==OCI==--
