#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add jetstack https://charts.jetstack.io

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.7.1 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.6.4 \
  --set hostname=rancher.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt

## --set rancherImageTag=v2.6.4-rc14 \


kubectl apply -f clusterissuer.yaml

watch "kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}' && kubectl get pods,ingress,certificates -A"