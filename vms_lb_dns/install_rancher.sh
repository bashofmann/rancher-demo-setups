#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add jetstack https://charts.jetstack.io

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.11.1 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook
helm repo add rancher-prime https://charts.rancher.com/server-charts/prime

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.7.3 \
  --set hostname=rancher.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt

kubectl apply -f clusterissuer.yaml

watch "kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}' && kubectl get pods,ingress,certificates -A"
