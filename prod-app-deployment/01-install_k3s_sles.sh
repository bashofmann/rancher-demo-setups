#!/usr/bin/env bash

set -e

$(terraform output -state=infra/terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 "sudo mkdir -p /var/lib/rancher/k3s/server/manifests"
dd if=k3s/traefik-config.yaml | ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo dd of=/var/lib/rancher/k3s/server/manifests/traefik-config.yaml

k3sup install \
  --ip $IP0 \
  --user ec2-user \
  --cluster \
  --k3s-extra-args "--node-external-ip ${IP0}" \
  --k3s-channel v1.21

k3sup join \
  --ip $IP1 \
  --user ec2-user \
  --server-user ec2-user \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP1}" \
  --k3s-channel v1.21

k3sup join \
  --ip $IP2 \
  --user ec2-user \
  --server-user ec2-user \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--node-external-ip ${IP2}" \
  --k3s-channel v1.21

k3sup join \
  --ip $IP3 \
  --user ec2-user \
  --server-user ec2-user \
  --server-ip $IP0 \
  --k3s-extra-args "--node-external-ip ${IP3}" \
  --k3s-channel v1.21

k3sup join \
  --ip $IP4 \
  --user ec2-user \
  --server-user ec2-user \
  --server-ip $IP0 \
  --k3s-extra-args "--node-external-ip ${IP4}" \
  --k3s-channel v1.21