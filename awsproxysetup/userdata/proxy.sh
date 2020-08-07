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

sudo curl -fsSL -o /usr/local/bin/rke https://github.com/rancher/rke/releases/download/v1.1.4/rke_linux-amd64
sudo chmod +x /usr/local/bin/rke

sudo apt-get install -y nginx

cat <<'EOF' | sudo tee /etc/nginx/nginx.conf > /dev/null
load_module /usr/lib/nginx/modules/ngx_stream_module.so;
worker_processes 4;
worker_rlimit_nofile 40000;
events {
    worker_connections 8192;
}
stream {
    upstream rancher_servers_http {
        least_conn;
        server 10.0.1.200:80 max_fails=3 fail_timeout=5s;
        server 10.0.1.201:80 max_fails=3 fail_timeout=5s;
        server 10.0.1.202:80 max_fails=3 fail_timeout=5s;
    }
    server {
        listen 80;
        proxy_pass rancher_servers_http;
    }

    upstream rancher_servers_https {
        least_conn;
        server 10.0.1.200:443 max_fails=3 fail_timeout=5s;
        server 10.0.1.201:443 max_fails=3 fail_timeout=5s;
        server 10.0.1.202:443 max_fails=3 fail_timeout=5s;
    }
    server {
        listen     443;
        proxy_pass rancher_servers_https;
    }
}
EOF

sudo service nginx reload
