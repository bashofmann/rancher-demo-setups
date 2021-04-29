#!/usr/bin/env bash

rm cluster.yml
rm cluster.rkestate
rm kube_config_cluster.yml

terraform destroy -auto-approve