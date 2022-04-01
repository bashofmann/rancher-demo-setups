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

kubectl apply -f cert-manager/cluster-issuer.yaml