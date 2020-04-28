#!/usr/bin/env bash

set -xe

export K3S_TOKEN='${k3s_token}'
%{ if k3s_url != "" }
export K3S_URL='${k3s_url}'
%{ endif }

until (curl -sfL https://get.k3s.io | sh -); do
  echo 'k3s did not install correctly'
  sleep 2
done

%{ if register_manifest_url != "" }

until kubectl get pods -A | grep 'Running';
do
  echo 'Waiting for k3s startup'
  sleep 5
done

kubectl apply -f ${register_manifest_url}

%{ endif }