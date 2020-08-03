#!/bin/bash -x

cat <<'EOF' | sudo tee /etc/apt/apt.conf.d/proxy.conf > /dev/null
Acquire::http::Proxy "http://${proxy_private_ip}:8888/";
Acquire::https::Proxy "http://${proxy_private_ip}:8888/";
EOF

export HTTP_PROXY=http://${proxy_private_ip}:8888
export HTTPS_PROXY=http://${proxy_private_ip}:8888

curl -sL https://releases.rancher.com/install-docker/19.03.sh | sh
sudo usermod -aG docker ubuntu

sudo mkdir -p mkdir /etc/systemd/system/docker.service.d
cat <<'EOF' | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf > /dev/null
[Service]
Environment="HTTP_PROXY=http://${proxy_private_ip}:8888"
Environment="HTTPS_PROXY=http://${proxy_private_ip}:8888"
Environment="NO_PROXY=127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
EOF

cat <<'EOF' | sudo tee /etc/docker/daemon.json > /dev/null
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    }
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker
