#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add jetstack https://charts.jetstack.io

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.5.2 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook