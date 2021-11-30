#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig_harbor

export harbor_pw=$(kubectl get secret -n harbor harbor-harbor-core -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" | base64 --decode)

docker login registry.plgrnd.be -u admin -p $harbor_pw

export RANCHER_VERSION=2.5.8
mkdir -p rancher_images
wget -O rancher_images/rancher-images.txt https://github.com/rancher/rancher/releases/download/v${RANCHER_VERSION}/rancher-images.txt
wget -O rancher_images/rancher-load-images.sh https://github.com/rancher/rancher/releases/download/v${RANCHER_VERSION}/rancher-load-images.sh
wget -O rancher_images/rancher-save-images.sh https://github.com/rancher/rancher/releases/download/v${RANCHER_VERSION}/rancher-save-images.sh

chmod +x rancher_images/*.sh

cd rancher_images

./rancher-save-images.sh --image-list ./rancher-images.txt

curl https://registry.plgrnd.be/api/v2.0/projects -X POST --data "@../harbor_rancher_project.json" -H 'Content-Type: application/json' -u admin:${harbor_pw}

./rancher-load-images.sh --image-list ./rancher-images.txt --registry registry.plgrnd.be

