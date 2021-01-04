#!/bin/bash -x

export K3S_KUBECONFIG_MODE=644

curl -sfL https://get.k3s.io | sh -

snap install helm --classic

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

helm repo add jetstack https://charts.jetstack.io
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.0.4 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager-webhook
