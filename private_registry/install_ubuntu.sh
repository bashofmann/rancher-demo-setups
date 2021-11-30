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

mv kubeconfig kubeconfig_rancher

export KUBECONFIG=$(pwd)/kubeconfig_harbor

export harbor_pw=$(kubectl get secret -n harbor harbor-harbor-core -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" | base64 --decode)

export KUBECONFIG=$(pwd)/kubeconfig_rancher

helm upgrade --install \
  ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.kind=DaemonSet \
  --set controller.hostPort.enabled=true \
  --set controller.service.type=ClusterIP \
  --create-namespace

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
  --version v1.2.0 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

kubectl create namespace cattle-system || true
kubectl create secret docker-registry harbor-secret -n cattle-system --docker-server=registry.plgrnd.be --docker-username=admin --docker-password=${harbor_pw}
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}' -n cattle-system
kubectl create namespace fleet-system || true
kubectl create secret docker-registry harbor-secret -n fleet-system --docker-server=registry.plgrnd.be --docker-username=admin --docker-password=${harbor_pw}
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "harbor-secret"}]}' -n fleet-system

helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version v2.5.8 \
  --set hostname=rancher.plgrnd.be --create-namespace \
  --set ingress.tls.source=letsEncrypt \
  --set rancherImage=registry.plgrnd.be/rancher/rancher \
  --set systemDefaultRegistry=registry.plgrnd.be \
  --set useBundledSystemChart=true \
  --set imagePullSecrets[0].name=harbor-secret

watch kubectl get pods,ingress -A  