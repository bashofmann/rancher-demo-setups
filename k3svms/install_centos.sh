#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

k3sup install \
  --ip $IP0 \
  --user centos \
  --cluster \
  --k3s-extra-args "--node-external-ip ${IP0}" \
  --k3s-channel latest

k3sup join \
  --ip $IP1 \
  --user centos \
  --server-user centos \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP1}" \
  --k3s-channel latest

k3sup join \
  --ip $IP2 \
  --user centos \
  --server-user centos \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP2}" \
  --k3s-channel latest

export KUBECONFIG=kubeconfig

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.0.4 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version 2.5.2 \
  --set hostname=rancher.${IP0}.xip.io --create-namespace

watch kubectl get pods,ingress -A  