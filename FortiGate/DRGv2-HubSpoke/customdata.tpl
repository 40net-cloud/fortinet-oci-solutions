Content-Type: multipart/mixed; boundary="==OCI=="
MIME-Version: 1.0

--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname ${fgt_vm_name}
end
config system sdn-connector
  edit oci-sdn
    set type oci
    set use-metadata-iam enable
  next
end
config system probe-response
  set http-probe-value OK
  set mode http-probe
end
config system interface
  edit port1
    set alias untrusted
    set mode static
    set ip ${port1_ip}/${port1_mask}
    set allowaccess ping https ssh fgfm probe-response
  next
  edit port2
    set alias trusted
    set mode static
    set ip ${port2_ip}/${port2_mask}
    set allowaccess ping https ssh fgfm probe-response
  next
end
config router static
  edit 1
    set device port1
    set gateway ${untrusted_gateway_ip}
  next
  edit 2
    set device port2
    set dst ${vcn_cidr}
    set gateway ${trusted_gateway_ip}
  next
  edit 3
    set device port2
    set dst ${spoke1_cidr}
    set gateway ${trusted_gateway_ip}
  next
  edit 4
    set device port2
    set dst ${spoke2_cidr}
    set gateway ${trusted_gateway_ip}
  next
end
config firewall policy
    edit 1
        set name "DRG traffic"
        set srcintf "port2"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set nat enable
    next
end

%{ if fgt_license_flexvm != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN:${fgt_license_flexvm}

%{ endif }
%{ if fgt_license_file != "" }
--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${fgt_license_file}

%{ endif }
--==OCI==--
