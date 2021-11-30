#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')
$(terraform output -state=terraform.tfstate -json "lb" | jq -r '"export LB=\(.)"')

ssh ubuntu@$IP4 wget -O install_docker.sh https://releases.rancher.com/install-docker/20.10.sh
ssh ubuntu@$IP4 bash install_docker.sh
ssh ubuntu@$IP4 sudo usermod -aG docker ubuntu
ssh ubuntu@$IP4 sudo snap install kubectl --classic
scp kubeconfig_harbor ubuntu@$IP4:~/kubeconfig_harbor
scp sync_rancher_images.sh ubuntu@$IP4:~/sync_rancher_images.sh
scp harbor_rancher_project.json ubuntu@$IP4:~/harbor_rancher_project.json