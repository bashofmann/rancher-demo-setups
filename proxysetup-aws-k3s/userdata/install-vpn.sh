#!/usr/bin/env bash

new_client () {
	# Generates the custom client.ovpn
	{
	cat /etc/openvpn/server/client-common.txt
	echo "<ca>"
	cat /etc/openvpn/server/easy-rsa/pki/ca.crt
	echo "</ca>"
	echo "<cert>"
	sed -ne '/BEGIN CERTIFICATE/,$ p' /etc/openvpn/server/easy-rsa/pki/issued/"$client".crt
	echo "</cert>"
	echo "<key>"
	cat /etc/openvpn/server/easy-rsa/pki/private/"$client".key
	echo "</key>"
	echo "<tls-crypt>"
	sed -ne '/BEGIN OpenVPN Static key/,$ p' /etc/openvpn/server/tc.key
	echo "</tls-crypt>"
	} > ~/"$client".ovpn
}
ip=$(ip -4 addr | grep inet | grep -vE '127(\.[0-9]{1,3}){3}' | cut -d '/' -f 1 | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}')
public_ip=$(grep -m 1 -oE '^[0-9]{1,3}(\.[0-9]{1,3}){3}$' <<< "$(wget -T 10 -t 1 -4qO- "http://ip1.dynupdate.no-ip.com/" || curl -m 10 -4Ls "http://ip1.dynupdate.no-ip.com/")")
protocol="udp"
port="1194"
client="awsproxysetup"
echo "OpenVPN installation is ready to begin."
os="ubuntu"
group_name="nogroup"
# Install a firewall in the rare case where one is not already available
if ! systemctl is-active --quiet firewalld.service && ! hash iptables 2>/dev/null; then
  if [[ "$os" == "centos" || "$os" == "fedora" ]]; then
    firewall="firewalld"
    # We don't want to silently enable firewalld, so we give a subtle warning
    # If the user continues, firewalld will be installed and enabled during setup
    echo "firewalld, which is required to manage routing tables, will also be installed."
  elif [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
    # iptables is way less invasive than firewalld so no warning is given
    firewall="iptables"
  fi
fi
# If running inside a container, disable LimitNPROC to prevent conflicts
if systemd-detect-virt -cq; then
  mkdir /etc/systemd/system/openvpn-server@server.service.d/ 2>/dev/null
  echo "[Service]
LimitNPROC=infinity" > /etc/systemd/system/openvpn-server@server.service.d/disable-limitnproc.conf
fi
if [[ "$os" = "debian" || "$os" = "ubuntu" ]]; then
  apt-get update
  apt-get install -y openvpn openssl ca-certificates $firewall
elif [[ "$os" = "centos" ]]; then
  yum install -y epel-release
  yum install -y openvpn openssl ca-certificates tar $firewall
else
  # Else, OS must be Fedora
  dnf install -y openvpn openssl ca-certificates tar $firewall
fi
# If firewalld was just installed, enable it
if [[ "$firewall" == "firewalld" ]]; then
  systemctl enable --now firewalld.service
fi
# Get easy-rsa
easy_rsa_url='https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.7/EasyRSA-3.0.7.tgz'
mkdir -p /etc/openvpn/server/easy-rsa/
{ wget -qO- "$easy_rsa_url" 2>/dev/null || curl -sL "$easy_rsa_url" ; } | tar xz -C /etc/openvpn/server/easy-rsa/ --strip-components 1
chown -R root:root /etc/openvpn/server/easy-rsa/
cd /etc/openvpn/server/easy-rsa/
# Create the PKI, set up the CA and the server and client certificates
./easyrsa init-pki
./easyrsa --batch build-ca nopass
EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-server-full server nopass
EASYRSA_CERT_EXPIRE=3650 ./easyrsa build-client-full "$client" nopass
EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
# Move the stuff we need
cp pki/ca.crt pki/private/ca.key pki/issued/server.crt pki/private/server.key pki/crl.pem /etc/openvpn/server
# CRL is read with each client connection, while OpenVPN is dropped to nobody
chown nobody:"$group_name" /etc/openvpn/server/crl.pem
# Without +x in the directory, OpenVPN can't run a stat() on the CRL file
chmod o+x /etc/openvpn/server/
# Generate key for tls-crypt
openvpn --genkey --secret /etc/openvpn/server/tc.key
# Create the DH parameters file using the predefined ffdhe2048 group
echo '-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEA//////////+t+FRYortKmq/cViAnPTzx2LnFg84tNpWp4TZBFGQz
+8yTnc4kmz75fS/jY2MMddj2gbICrsRhetPfHtXV/WVhJDP1H18GbtCFY2VVPe0a
87VXE15/V8k1mE8McODmi3fipona8+/och3xWKE2rec1MKzKT0g6eXq8CrGCsyT7
YdEIqUuyyOP7uWrat2DX9GgdT0Kj3jlN9K5W7edjcrsZCwenyO4KbXCeAvzhzffi
7MA0BM0oNC9hkXL+nOmFg/+OTxIy7vKBg8P+OxtMb61zO7X8vC7CIAXFjvGDfRaD
ssbzSibBsu/6iGtCOGEoXJf//////////wIBAg==
-----END DH PARAMETERS-----' > /etc/openvpn/server/dh.pem
# Generate server.conf
echo "local $ip
port $port
proto $protocol
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
auth SHA512
tls-crypt tc.key
topology subnet
server 10.8.0.0 255.255.255.0" > /etc/openvpn/server/server.conf
# IPv6
if [[ -z "$ip6" ]]; then
  echo 'push "redirect-gateway def1 bypass-dhcp"' >> /etc/openvpn/server/server.conf
else
  echo 'server-ipv6 fddd:1194:1194:1194::/64' >> /etc/openvpn/server/server.conf
  echo 'push "redirect-gateway def1 ipv6 bypass-dhcp"' >> /etc/openvpn/server/server.conf
fi
echo 'ifconfig-pool-persist ipp.txt' >> /etc/openvpn/server/server.conf
# DNS
case "$dns" in
  1|"")
    # Locate the proper resolv.conf
    # Needed for systems running systemd-resolved
    if grep -q '^nameserver 127.0.0.53' "/etc/resolv.conf"; then
      resolv_conf="/run/systemd/resolve/resolv.conf"
    else
      resolv_conf="/etc/resolv.conf"
    fi
    # Obtain the resolvers from resolv.conf and use them for OpenVPN
    grep -v '^#\|^;' "$resolv_conf" | grep '^nameserver' | grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' | while read line; do
      echo "push \"dhcp-option DNS $line\"" >> /etc/openvpn/server/server.conf
    done
  ;;
  2)
    echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server/server.conf
    echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server/server.conf
  ;;
  3)
    echo 'push "dhcp-option DNS 1.1.1.1"' >> /etc/openvpn/server/server.conf
    echo 'push "dhcp-option DNS 1.0.0.1"' >> /etc/openvpn/server/server.conf
  ;;
  4)
    echo 'push "dhcp-option DNS 208.67.222.222"' >> /etc/openvpn/server/server.conf
    echo 'push "dhcp-option DNS 208.67.220.220"' >> /etc/openvpn/server/server.conf
  ;;
  5)
    echo 'push "dhcp-option DNS 9.9.9.9"' >> /etc/openvpn/server/server.conf
    echo 'push "dhcp-option DNS 149.112.112.112"' >> /etc/openvpn/server/server.conf
  ;;
  6)
    echo 'push "dhcp-option DNS 176.103.130.130"' >> /etc/openvpn/server/server.conf
    echo 'push "dhcp-option DNS 176.103.130.131"' >> /etc/openvpn/server/server.conf
  ;;
esac
echo "keepalive 10 120
cipher AES-256-CBC
user nobody
group $group_name
persist-key
persist-tun
status openvpn-status.log
verb 3
crl-verify crl.pem" >> /etc/openvpn/server/server.conf
if [[ "$protocol" = "udp" ]]; then
  echo "explicit-exit-notify" >> /etc/openvpn/server/server.conf
fi
# Enable net.ipv4.ip_forward for the system
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/30-openvpn-forward.conf
# Enable without waiting for a reboot or service restart
echo 1 > /proc/sys/net/ipv4/ip_forward
if [[ -n "$ip6" ]]; then
  # Enable net.ipv6.conf.all.forwarding for the system
  echo "net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.d/30-openvpn-forward.conf
  # Enable without waiting for a reboot or service restart
  echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
fi
if systemctl is-active --quiet firewalld.service; then
  # Using both permanent and not permanent rules to avoid a firewalld
  # reload.
  # We don't use --add-service=openvpn because that would only work with
  # the default port and protocol.
  firewall-cmd --add-port="$port"/"$protocol"
  firewall-cmd --zone=trusted --add-source=10.8.0.0/24
  firewall-cmd --permanent --add-port="$port"/"$protocol"
  firewall-cmd --permanent --zone=trusted --add-source=10.8.0.0/24
  # Set NAT for the VPN subnet
  firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
  firewall-cmd --permanent --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to "$ip"
  if [[ -n "$ip6" ]]; then
    firewall-cmd --zone=trusted --add-source=fddd:1194:1194:1194::/64
    firewall-cmd --permanent --zone=trusted --add-source=fddd:1194:1194:1194::/64
    firewall-cmd --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
    firewall-cmd --permanent --direct --add-rule ipv6 nat POSTROUTING 0 -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to "$ip6"
  fi
else
  # Create a service to set up persistent iptables rules
  iptables_path=$(command -v iptables)
  ip6tables_path=$(command -v ip6tables)
  # nf_tables is not available as standard in OVZ kernels. So use iptables-legacy
  # if we are in OVZ, with a nf_tables backend and iptables-legacy is available.
  if [[ $(systemd-detect-virt) == "openvz" ]] && readlink -f "$(command -v iptables)" | grep -q "nft" && hash iptables-legacy 2>/dev/null; then
    iptables_path=$(command -v iptables-legacy)
    ip6tables_path=$(command -v ip6tables-legacy)
  fi
  echo "[Unit]
Before=network.target
[Service]
Type=oneshot
ExecStart=$iptables_path -t nat -A POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStart=$iptables_path -I INPUT -p $protocol --dport $port -j ACCEPT
ExecStart=$iptables_path -I FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStart=$iptables_path -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$iptables_path -t nat -D POSTROUTING -s 10.8.0.0/24 ! -d 10.8.0.0/24 -j SNAT --to $ip
ExecStop=$iptables_path -D INPUT -p $protocol --dport $port -j ACCEPT
ExecStop=$iptables_path -D FORWARD -s 10.8.0.0/24 -j ACCEPT
ExecStop=$iptables_path -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" > /etc/systemd/system/openvpn-iptables.service
  if [[ -n "$ip6" ]]; then
    echo "ExecStart=$ip6tables_path -t nat -A POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStart=$ip6tables_path -I FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStart=$ip6tables_path -I FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
ExecStop=$ip6tables_path -t nat -D POSTROUTING -s fddd:1194:1194:1194::/64 ! -d fddd:1194:1194:1194::/64 -j SNAT --to $ip6
ExecStop=$ip6tables_path -D FORWARD -s fddd:1194:1194:1194::/64 -j ACCEPT
ExecStop=$ip6tables_path -D FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/systemd/system/openvpn-iptables.service
  fi
  echo "RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/openvpn-iptables.service
  systemctl enable --now openvpn-iptables.service
fi
# If the server is behind NAT, use the correct IP address
[[ -n "$public_ip" ]] && ip="$public_ip"
# client-common.txt is created so we have a template to add further users later
echo "client
dev tun
proto $protocol
remote $ip $port
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
auth SHA512
cipher AES-256-CBC
ignore-unknown-option block-outside-dns
block-outside-dns
verb 3" > /etc/openvpn/server/client-common.txt
# Enable and start the OpenVPN service
systemctl enable --now openvpn-server@server.service
# Generates the custom client.ovpn
new_client
echo
echo "Finished!"
echo
echo "The client configuration is available in:" ~/"$client.ovpn"
echo "New clients can be added by running this script again."