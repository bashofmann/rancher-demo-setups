#!/usr/bin/env bash

set -e

terraform apply -auto-approve
bash install_k3s_sles.sh
bash install_rancher.sh
