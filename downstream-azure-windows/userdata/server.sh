#!/bin/bash -x

export DEBIAN_FRONTEND=noninteractive
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

docker pull stedolan/jq

ipData=$(curl -H "Metadata: true" http://169.254.169.254/metadata/instance/network?api-version=2019-06-01 \
  | docker run --rm -i stedolan/jq .interface[0].ipv4.ipAddress[0])

publicIP=$(echo $ipData | docker run --rm -i stedolan/jq -r .publicIpAddress)
privateIP=$(echo $ipData | docker run --rm -i stedolan/jq -r .privateIpAddress)

${register_command} --address $publicIP --internal-address $privateIP --etcd --controlplane --worker



