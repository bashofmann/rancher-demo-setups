install: add-helm-repos install-sealed-secrets install-cert-manager install-external-dns install-demo-shop install-rancher-demo install-mysql-operator install-loki install-rio install-argocd install-weave-scope helm-whatup

add-helm-repos:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add jetstack https://charts.jetstack.io
	helm repo add presslabs https://presslabs.github.io/charts
	helm repo add loki https://grafana.github.io/loki/charts
	helm repo add oteemo https://oteemo.github.io/charts/
	helm repo add codecentric https://codecentric.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo update

install-sealed-secrets:
	helm upgrade --install --namespace kube-system sealed-secrets-controller stable/sealed-secrets  --version v1.10.3

install-cert-manager:
	kubectl create namespace istio-system || true
	kubectl create namespace cert-manager || true
	kubectl label namespace cert-manager field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace cert-manager field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.15.2 --set installCRDs=true --wait
	cat cert-manager/clusterissuer.yaml | envsubst | kubectl apply -f -
	cat cert-manager/credentials-secret.yaml | envsubst | kubectl apply -f -

install-external-dns:
	kubectl create namespace external-dns || true
	kubectl label namespace external-dns field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace external-dns field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install external-dns bitnami/external-dns --namespace=external-dns --version 3.2.5 -f external-dns/values.yaml --set digitalocean.apiToken=$(DIGITALOCEAN_TOKEN) --set txtOwnerId=$(DNS_TXT_OWNER_ID)

install-mysql-operator:
	kubectl create namespace mysql-operator || true
	kubectl label namespace mysql-operator field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace mysql-operator field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl apply -f mysql-operator/basic-auth.yaml
	cat mysql-operator/values.yaml | envsubst | helm upgrade --install mysql-operator presslabs/mysql-operator --namespace mysql-operator --version 0.4.0 -f -

install-demo-shop:
	kubectl create namespace shop || true
	kubectl label namespace shop istio-injection=enabled || true
	kubectl apply -f demo-shop/demo-shop.yaml -n shop
	cat demo-shop/ingress.yaml | envsubst | kubectl apply -n shop -f -
	cat demo-shop/cert.yaml | envsubst | kubectl apply -f -
	cat demo-shop/ingressgateway.yaml | envsubst | kubectl apply -f -

install-bookinfo:
	kubectl create namespace bookinfo || true
	kubectl label namespace bookinfo istio-injection=enabled || true
	kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/platform/kube/bookinfo.yaml
	kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.6/samples/bookinfo/networking/destination-rule-all.yaml
	kubectl apply -f bookinfo

install-rancher-demo:
	cat rancher-demo/deployment.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/service.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/ingress.yaml | envsubst | kubectl apply -f -

install-loki:
	kubectl create namespace loki || true
	kubectl label namespace loki field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace loki field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install loki loki/loki-stack --namespace loki --version 0.38.3 -f loki/values.yaml
	#kubectl apply -f loki/datasource.yaml
	#kubectl rollout restart deployment -n cattle-prometheus grafana-cluster-monitoring

install-rio:
	# rio install --email $(EMAIL)
	# kubectl label namespace linkerd field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	# kubectl label namespace rio-system field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true

install-argocd:
	kubectl create namespace argocd || true
	kubectl label namespace argocd field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace argocd field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	cat argocd/ingress.yaml | envsubst | kubectl apply -f -

install-nexus:
	kubectl create namespace nexus || true
	kubectl label namespace nexus field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace nexus field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install nexus oteemo/sonatype-nexus --namespace nexus --version 2.1.0 -f nexus/values.yaml

install-keycloak:
	kubectl create namespace keycloak || true
	kubectl label namespace keycloak field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace keycloak field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install keycloak codecentric/keycloak --namespace keycloak --version 9.0.1 -f keycloak/values.yaml

install-elk:
	kubectl create namespace logging || true
	kubectl label namespace logging field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace logging field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl apply -f elk/basic-auth.yaml
	helm upgrade --install elasticsearch elastic/elasticsearch --version 7.8.1 --namespace logging -f elk/elasticsearch/values.yaml
	helm upgrade --install kibana elastic/kibana --version 7.8.1 --namespace logging -f elk/kibana/values.yaml

install-weave-scope:
	kubectl create namespace weave-scope || true
	kubectl label namespace weave-scope field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl annotate namespace weave-scope field.cattle.io/projectId=$(CLUSTER_ID):$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl apply -f weave-scope/basic-auth.yaml
	cat weave-scope/values.yaml | envsubst | helm upgrade --install weave-scope  stable/weave-scope  --namespace weave-scope  --version 1.1.10 -f -

install-harbor:
	kubectl create namespace harbor || true
	helm upgrade --install harbor harbor/harbor --version 1.5.0 --namespace harbor -f harbor/values.yaml
	kubectl apply -f harbor/certificate.yaml

helm-whatup:
#	helm whatup does not work with helm3 yet