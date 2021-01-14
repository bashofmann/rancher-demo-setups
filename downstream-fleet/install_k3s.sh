#!/usr/bin/env bash

set -e

k3sup install \
  --ip $IP \
  --user ec2-user \
  --k3s-extra-args "--node-external-ip ${IP}" \
  --k3s-channel v1.19
