#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

export KUBECONFIG=kube_config_cluster.yml

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.2.0 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version 2.5.8 \
  --set replicas=1 \
  --set hostname=rancher.${IP0}.nip.io --create-namespace

watch kubectl get pods,ingress -A
