#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')
$(terraform output -state=terraform.tfstate -json "lb" | jq -r '"export LB=\(.)"')

k3sup install \
  --ip $IP0 \
  --user ubuntu \
  --cluster \
  --k3s-extra-args "--node-external-ip ${IP0}" \
  --k3s-channel v1.19

k3sup join \
  --ip $IP1 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP1}" \
  --k3s-channel v1.19

k3sup join \
  --ip $IP2 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP2}" \
  --k3s-channel v1.19

export KUBECONFIG=$(pwd)/kubeconfig

#kubectl create namespace ingress-nginx | true
#kubectl -n ingress-nginx create service externalname external --external-name ${LB} || true
#
#helm upgrade --install \
#  ingress-nginx ingress-nginx/ingress-nginx \
#  --namespace ingress-nginx \
#  --set controller.kind=DaemonSet \
#  --set controller.hostPort.enabled=true \
#  --set controller.service.type=ClusterIP \
#  --set-string controller.config.use-proxy-protocol=true \
#  --set controller.publishService.pathOverride=ingress-nginx/external \
#  --version 3.12.0 --create-namespace
helm repo add jetstack https://charts.jetstack.io

helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.0.4 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.5.5 \
  --set hostname=rancher.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt

watch kubectl get pods,ingress -A  