#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

export KUBECONFIG=kube_config_cluster.yml

kubectl apply -f cloud-config.yaml

helm repo add azurefile-csi-driver https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/charts
helm upgrade --install azurefile-csi-driver azurefile-csi-driver/azurefile-csi-driver \
  --namespace kube-system \
  --set controller.replicas=1	\
  --set windows.enabled=false

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/azurefile-csi-driver/master/deploy/example/storageclass-azurefile-csi.yaml
