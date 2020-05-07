#!/bin/bash -x

curl -sL https://releases.rancher.com/install-docker/${docker_version}.sh | sh
sudo usermod -aG docker ${username}

cat <<'EOF' | sudo tee /etc/docker/daemon.json > /dev/null
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    }
}
EOF

sudo systemctl restart docker
