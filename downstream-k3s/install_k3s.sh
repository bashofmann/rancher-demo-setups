#!/usr/bin/env bash

set -e

k3sup install \
  --ip $IP0 \
  --user ubuntu \
  --cluster \
  --k3s-extra-args "--disable local-storage --node-external-ip ${IP0}" \
  --k3s-channel latest

k3sup join \
  --ip $IP1 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--disable local-storage --node-external-ip ${IP1}" \
  --k3s-channel latest

k3sup join \
  --ip $IP2 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--disable local-storage --node-external-ip ${IP2}" \
  --k3s-channel latest

k3sup join \
  --ip $IP3 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--disable local-storage --node-external-ip ${IP3}" \
  --k3s-channel latest

k3sup join \
  --ip $IP4 \
  --user ubuntu \
  --server-user ubuntu \
  --server-ip $IP0 \
  --server \
  --k3s-extra-args "--disable local-storage --node-external-ip ${IP4}" \
  --k3s-channel latest
