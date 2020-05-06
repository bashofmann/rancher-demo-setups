install: add-helm-repos install-sealed-secrets install-cert-manager install-external-dns install-demo-shop install-mysql-operator install-loki install-rio install-argocd helm-whatup

add-helm-repos:
	helm repo add stable https://kubernetes-charts.storage.googleapis.com/
	helm repo add jetstack https://charts.jetstack.io
	helm repo add presslabs https://presslabs.github.io/charts
	helm repo add loki https://grafana.github.io/loki/charts
	helm repo update

install-sealed-secrets:
	helm upgrade --install --namespace kube-system sealed-secrets-controller stable/sealed-secrets  --version v1.8.0

install-cert-manager:
	kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.14/deploy/manifests/00-crds.yaml
	kubectl create namespace cert-manager || true
	kubectl label namespace cert-manager field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.14.3 --wait
	cat cert-manager/clusterissuer.yaml | envsubst | kubectl apply -f -
	cat cert-manager/credentials-secret.yaml | envsubst | kubectl apply -f -

install-external-dns:
	kubectl create namespace external-dns || true
	kubectl label namespace external-dns field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install external-dns bitnami/external-dns --namespace=external-dns --version 2.20.4 -f external-dns/values.yaml --set digitalocean.apiToken=$(DIGITALOCEAN_TOKEN) --set txtOwnerId=$(DNS_TXT_OWNER_ID)

install-mysql-operator:
	kubectl create namespace mysql-operator || true
	kubectl label namespace mysql-operator field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install mysql-operator presslabs/mysql-operator --namespace mysql-operator --version 0.4.0-rc.1 -f mysql-operator/values.yaml

install-demo-shop:
	kubectl create namespace shop || true
	kubectl label namespace shop istio-injection=enabled || true
	kubectl apply -f demo-shop/demo-shop.yaml -n shop
	cat demo-shop/ingress.yaml | envsubst | kubectl apply -n shop -f -

install-rancher-demo:
	cat rancher-demo/deployment.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/service.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/ingress.yaml | envsubst | kubectl apply -f -

install-loki:
	kubectl create namespace loki || true
	kubectl label namespace loki field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	helm upgrade --install loki loki/loki-stack --namespace loki --version 0.34.2 -f loki/values.yaml
	#kubectl apply -f loki/datasource.yaml
	#kubectl rollout restart deployment -n cattle-prometheus grafana-cluster-monitoring

install-rio:
	# rio install --email $(EMAIL)
	# kubectl label namespace linkerd field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	# kubectl label namespace rio-system field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true

install-argocd:
	kubectl create namespace argocd || true
	kubectl label namespace argocd field.cattle.io/projectId=$(RANCHER_SYSTEM_PROJECT_ID) || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	cat argocd/ingress.yaml | envsubst | kubectl apply -f -


helm-whatup:
#	helm whatup does not work with helm3 yet