#!/usr/bin/env bash

set -e

$(terraform output -state=terraform.tfstate -json node_ips | jq -r 'keys[] as $k | "export IP\($k)=\(.[$k])"')

ssh -o StrictHostKeyChecking=no ec2-user@$IP0 sudo /usr/local/bin/k3s-uninstall.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP1 sudo /usr/local/bin/k3s-uninstall.sh
ssh -o StrictHostKeyChecking=no ec2-user@$IP2 sudo /usr/local/bin/k3s-uninstall.sh