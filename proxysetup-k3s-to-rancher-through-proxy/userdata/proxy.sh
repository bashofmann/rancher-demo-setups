#!/bin/bash -x

sudo apt-get update

sudo apt-get install -y tinyproxy

cat <<'EOF' | sudo tee /etc/tinyproxy/tinyproxy.conf > /dev/null
User tinyproxy
Group tinyproxy

Port 8888

Timeout 600

DefaultErrorFile "/usr/share/tinyproxy/default.html"

StatFile "/usr/share/tinyproxy/stats.html"

Logfile "/var/log/tinyproxy/tinyproxy.log"

LogLevel Info

PidFile "/run/tinyproxy/tinyproxy.pid"

MaxClients 100

MinSpareServers 5
MaxSpareServers 20

StartServers 10

MaxRequestsPerChild 0

Allow 127.0.0.1
Allow 10.0.0.0/8

ViaProxyName "tinyproxy"

ConnectPort 80
ConnectPort 443
ConnectPort 563

EOF

sudo service tinyproxy restart

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod +x get_helm.sh
sudo ./get_helm.sh

