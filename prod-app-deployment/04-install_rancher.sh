#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.6.2 \
  --set hostname=rancher.k8sdemo.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt

watch "kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}' && kubectl get pods,ingress,certificates -A"