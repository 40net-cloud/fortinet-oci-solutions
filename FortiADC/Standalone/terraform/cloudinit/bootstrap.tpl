Content-Type: multipart/mixed; boundary="==OCI=="
MIME-Version: 1.0

--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system global
  set hostname "${hostname}"
end
config system interface
  edit port1
    set mode DHCP
    set allowaccess ping https ssh
  next
  edit port2
    set mode static
    set ip ${backend_ip} ${backend_netmask}
    set allowaccess ping
  next
end

--==OCI==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit

--==OCI==--
