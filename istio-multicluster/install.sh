#!/usr/bin/env bash

set -e

#Create do-secret.yaml with DO access token

helm repo add rancher-charts https://charts.rancher.io

#Create two DO clusters with cloud provider external
#Get local kubeconfig with both clusters

export CTX_CLUSTER1=bhofmann-cluster-one
export CTX_CLUSTER2=bhofmann-cluster-two

#do cloud provider
kubectl --context="${CTX_CLUSTER1}" apply -f do-secret.yaml
kubectl --context="${CTX_CLUSTER2}" apply -f do-secret.yaml

kubectl --context="${CTX_CLUSTER1}" apply -f https://raw.githubusercontent.com/digitalocean/digitalocean-cloud-controller-manager/v0.1.30/releases/v0.1.30.yml
kubectl --context="${CTX_CLUSTER2}" apply -f https://raw.githubusercontent.com/digitalocean/digitalocean-cloud-controller-manager/v0.1.30/releases/v0.1.30.yml

#install monitoring
helm --kube-context="${CTX_CLUSTER1}" upgrade --install --namespace cattle-monitoring-system rancher-monitoring-crd rancher-charts/rancher-monitoring-crd --create-namespace --wait
helm --kube-context="${CTX_CLUSTER1}" upgrade --install --namespace cattle-monitoring-system rancher-monitoring rancher-charts/rancher-monitoring --create-namespace --set prometheus.prometheusSpec.resources.limits.memory=2500Mi

helm --kube-context="${CTX_CLUSTER2}" upgrade --install --namespace cattle-monitoring-system rancher-monitoring-crd rancher-charts/rancher-monitoring-crd --create-namespace --wait
helm --kube-context="${CTX_CLUSTER2}" upgrade --install --namespace cattle-monitoring-system rancher-monitoring rancher-charts/rancher-monitoring --create-namespace --set prometheus.prometheusSpec.resources.limits.memory=2500Mi

#generate certs: https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/
#install cacerts
kubectl --context="${CTX_CLUSTER1}" create namespace istio-system
kubectl --context="${CTX_CLUSTER1}" create secret generic cacerts -n istio-system \
      --from-file=certs/cluster1/ca-cert.pem \
      --from-file=certs/cluster1/ca-key.pem \
      --from-file=certs/cluster1/root-cert.pem \
      --from-file=certs/cluster1/cert-chain.pem

kubectl --context="${CTX_CLUSTER2}" create namespace istio-system
kubectl --context="${CTX_CLUSTER2}" create secret generic cacerts -n istio-system \
      --from-file=certs/cluster2/ca-cert.pem \
      --from-file=certs/cluster2/ca-key.pem \
      --from-file=certs/cluster2/root-cert.pem \
      --from-file=certs/cluster2/cert-chain.pem

#Set the default network for cluster1
kubectl --context="${CTX_CLUSTER1}" get namespace istio-system && \
  kubectl --context="${CTX_CLUSTER1}" label namespace istio-system topology.istio.io/network=network1

#Configure cluster1 as a primary
istioctl install --context="${CTX_CLUSTER1}" -f cluster1.yaml -y

#Install the east-west gateway in cluster1
./gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster1 --network network1 | \
    istioctl --context="${CTX_CLUSTER1}" install -y -f -
#wait until svc has external IP
watch kubectl --context="${CTX_CLUSTER1}" describe svc istio-eastwestgateway -n istio-system

#Expose services in cluster1
kubectl --context="${CTX_CLUSTER1}" apply -n istio-system -f \
    expose-services-gateway.yaml

#####################

#Set the default network for cluster2
kubectl --context="${CTX_CLUSTER2}" get namespace istio-system && \
  kubectl --context="${CTX_CLUSTER2}" label namespace istio-system topology.istio.io/network=network2

#Configure cluster2 as a primary
istioctl install --context="${CTX_CLUSTER2}" -f cluster2.yaml -y

#Install the east-west gateway in cluster2
./gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster cluster2 --network network2 | \
    istioctl --context="${CTX_CLUSTER2}" install -y -f -
#wait until svc has external IP
watch kubectl --context="${CTX_CLUSTER2}" describe svc istio-eastwestgateway -n istio-system

#Expose services in cluster2
kubectl --context="${CTX_CLUSTER2}" apply -n istio-system -f \
    expose-services-gateway.yaml

#Enable Endpoint Discovery
istioctl x create-remote-secret \
  --context="${CTX_CLUSTER1}" \
  --name=cluster1 | \
  kubectl apply -f - --context="${CTX_CLUSTER2}"

istioctl x create-remote-secret \
  --context="${CTX_CLUSTER2}" \
  --name=cluster2 | \
  kubectl apply -f - --context="${CTX_CLUSTER1}"

#Kiali
helm --kube-context="${CTX_CLUSTER1}" upgrade --install --namespace istio-system rancher-kiali-server-crd rancher-charts/rancher-kiali-server-crd --create-namespace --wait
helm --kube-context="${CTX_CLUSTER2}" upgrade --install --namespace istio-system rancher-kiali-server-crd rancher-charts/rancher-kiali-server-crd --create-namespace --wait
helm --kube-context="${CTX_CLUSTER1}" upgrade --install --namespace istio-system rancher-kiali rancher-charts/rancher-kiali-server --create-namespace --wait -f kiali-values.yaml
helm --kube-context="${CTX_CLUSTER2}" upgrade --install --namespace istio-system rancher-kiali rancher-charts/rancher-kiali-server --create-namespace --wait -f kiali-values.yaml


#Verify
kubectl create --context="${CTX_CLUSTER1}" namespace sample
kubectl create --context="${CTX_CLUSTER2}" namespace sample

kubectl label --context="${CTX_CLUSTER1}" namespace sample \
    istio-injection=enabled
kubectl label --context="${CTX_CLUSTER2}" namespace sample \
    istio-injection=enabled

kubectl apply --context="${CTX_CLUSTER1}" \
    -f helloworld_service.yaml \
    -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f helloworld_service.yaml \
    -n sample

kubectl apply --context="${CTX_CLUSTER1}" \
    -f helloworld_v1.yaml \
    -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f helloworld_v2.yaml \
    -n sample
kubectl rollout status deployment --context="${CTX_CLUSTER1}" -n sample helloworld-v1
kubectl rollout status deployment --context="${CTX_CLUSTER2}" -n sample helloworld-v2


kubectl apply --context="${CTX_CLUSTER1}" \
    -f sleep.yaml -n sample
kubectl apply --context="${CTX_CLUSTER2}" \
    -f sleep.yaml -n sample
kubectl rollout status deployment --context="${CTX_CLUSTER1}" -n sample sleep
kubectl rollout status deployment --context="${CTX_CLUSTER2}" -n sample sleep

kubectl exec --context="${CTX_CLUSTER1}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER1}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl helloworld.sample:5000/hello


kubectl exec --context="${CTX_CLUSTER2}" -n sample -c sleep \
    "$(kubectl get pod --context="${CTX_CLUSTER2}" -n sample -l \
    app=sleep -o jsonpath='{.items[0].metadata.name}')" \
    -- curl helloworld.sample:5000/hello

