#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')
$(terraform output -state=terraform.tfstate -json "lb" | jq -r '"export LB=\(.)"')

k3sup install \
  --ip $IP3 \
  --user ubuntu \
  --cluster \
  --k3s-extra-args "--node-external-ip ${IP3}" \
  --k3s-channel v1.19

mv kubeconfig kubeconfig_harbor

export KUBECONFIG=$(pwd)/kubeconfig_harbor
export HELM_EXPERIMENTAL_OCI=1
export ENCODED_DIGITALOCEAN_TOKEN=$(awk -F "=" '/digitalocean_token/ {print $2}' terraform.tfvars | tr -d '" \n' | base64 -w 0)

make -C ../modules/demo-workloads -e install-cert-manager

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

make -C ../modules/demo-workloads -e install-harbor-standalone

watch kubectl get pods,ingress -A  