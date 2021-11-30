#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add bitnami https://charts.bitnami.com/bitnami

DIGITALOCEAN_TOKEN=$(cat infra/terraform.tfvars | grep digitalocean_token | cut -d '"' -f 2)

helm upgrade --install external-dns bitnami/external-dns \
  --namespace external-dns --version 4.5.1 \
  -f external-dns/values.yaml \
  --set digitalocean.apiToken=${DIGITALOCEAN_TOKEN} --create-namespace
