#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')


k3sup install \
  --ip $IP3 \
  --user ubuntu \
  --cluster \
  --k3s-channel latest

k3sup join \
  --ip $IP4 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP3 \
  --server \
  --k3s-channel latest

k3sup join \
  --ip $IP5 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP3 \
  --server \
  --k3s-channel latest

mv kubeconfig kubeconfig_cluster_one

k3sup install \
  --ip $IP6 \
  --user ubuntu \
  --k3s-channel latest

mv kubeconfig kubeconfig_cluster_two

k3sup install \
  --ip $IP7 \
  --user ubuntu \
  --k3s-channel latest

mv kubeconfig kubeconfig_cluster_three