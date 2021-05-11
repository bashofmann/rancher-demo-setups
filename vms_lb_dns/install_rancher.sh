#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add jetstack https://charts.jetstack.io

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.3.1 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.5.8 \
  --set hostname=rancher.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt

watch kubectl get pods,ingress -A