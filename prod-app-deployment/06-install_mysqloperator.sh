#!/usr/bin/env bash

set -e

export KUBECONFIG=$(pwd)/kubeconfig

helm repo add presslabs https://presslabs.github.io/charts

helm upgrade --install mysql-operator presslabs/mysql-operator --namespace mysql-operator --create-namespace -f mysql-operator/values.yaml

kubectl apply -f mysql-operator/navlink.yaml