#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

ssh -o StrictHostKeyChecking=no ubuntu@$IP0 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_KUBECONFIG_MODE=644 K3S_CLUSTER_INIT=1 sh -"
ssh -o StrictHostKeyChecking=no ubuntu@$IP1 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_URL=https://${IP0}:6443 sh - "
ssh -o StrictHostKeyChecking=no ubuntu@$IP2 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_URL=https://${IP0}:6443 sh - "

scp -o StrictHostKeyChecking=no ubuntu@$IP0:/etc/rancher/k3s/k3s.yaml kubeconfig
sed -i "s/127.0.0.1/${IP0}/g" kubeconfig

export KUBECONFIG=kubeconfig

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.0.4 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version 2.5.1 \
  --set hostname=rancher.${IP0}.xip.io --create-namespace

watch kubectl get pods,ingress -A  