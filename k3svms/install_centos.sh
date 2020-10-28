#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

ssh -o StrictHostKeyChecking=no centos@$IP0 "sudo yum install -y container-selinux selinux-policy-base"
ssh -o StrictHostKeyChecking=no centos@$IP1 "sudo yum install -y container-selinux selinux-policy-base"
ssh -o StrictHostKeyChecking=no centos@$IP2 "sudo yum install -y container-selinux selinux-policy-base"
ssh -o StrictHostKeyChecking=no centos@$IP0 "sudo yum install -y https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm"
ssh -o StrictHostKeyChecking=no centos@$IP1 "sudo yum install -y https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm"
ssh -o StrictHostKeyChecking=no centos@$IP2 "sudo yum install -y https://rpm.rancher.io/k3s-selinux-0.1.1-rc1.el7.noarch.rpm"
ssh -o StrictHostKeyChecking=no centos@$IP0 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_KUBECONFIG_MODE=644 K3S_CLUSTER_INIT=1 sh -"
ssh -o StrictHostKeyChecking=no centos@$IP1 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_URL=https://${IP0}:6443 sh - "
ssh -o StrictHostKeyChecking=no centos@$IP2 "curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=v1.19 INSTALL_K3S_EXEC='server' K3S_TOKEN=mysecret K3S_URL=https://${IP0}:6443 sh - "

scp -o StrictHostKeyChecking=no centos@$IP0:/etc/rancher/k3s/k3s.yaml kubeconfig
sed -i "s/127.0.0.1/${IP0}/g" kubeconfig

export KUBECONFIG=kubeconfig

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true \
  --version v1.0.3 --create-namespace

kubectl rollout status deployment -n cert-manager cert-manager
kubectl rollout status deployment -n cert-manager cert-manager-webhook

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --version 2.5.1 \
  --set hostname=rancher.${IP0}.xip.io --create-namespace

watch kubectl get pods,ingress -A  