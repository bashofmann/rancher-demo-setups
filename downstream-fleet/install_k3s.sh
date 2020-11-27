#!/usr/bin/env bash

set -e

k3sup install \
  --ip $IP \
  --user ubuntu \
  --k3s-extra-args "--node-external-ip ${IP}" \
  --k3s-channel latest
