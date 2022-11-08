Content-Type: multipart/mixed; boundary="==OCI=="
MIME-Version: 1.0

--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname ${fwb_vm_name}-B
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
    set mode dhcp
    set allowaccess ping https ssh fgfm probe-response
  next
end
config router static
  edit 1
    set device port1
    set gateway ${untrusted_gateway_ip}
  next
end

%{ if fwb_license_flexvm != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

LICENSE-TOKEN:${fwb_license_flexvm}

%{ endif }
%{ if fwb_license_file != "" }
--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="license"

${fwb_license_file}

%{ endif }
--==OCI==--
