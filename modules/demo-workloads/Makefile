install: add-helm-repos install-rancher-addons install-sealed-secrets install-cert-manager install-external-dns install-harbor install-demo-shop install-rancher-demo install-mysql-operator install-loki install-rio install-argocd install-weave-scope

add-helm-repos:
	helm repo add stable https://charts.helm.sh/stable
	helm repo add jetstack https://charts.jetstack.io
	helm repo add presslabs https://presslabs.github.io/charts
	helm repo add loki https://grafana.github.io/loki/charts
	helm repo add oteemo https://oteemo.github.io/charts/
	helm repo add codecentric https://codecentric.github.io/helm-charts
	helm repo add elastic https://helm.elastic.co
	helm repo add harbor https://helm.goharbor.io
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add linkerd https://helm.linkerd.io/stable
	helm repo add longhorn https://charts.longhorn.io
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo add trow https://trow.io
	helm repo add rancher-charts https://charts.rancher.io
	helm repo update

install-rancher-addons:
	kubectl config use-context bhofmann-demo-bhofmann-demo-control1 || true
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring-crd rancher-charts/rancher-monitoring-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-monitoring-system rancher-monitoring rancher-charts/rancher-monitoring --create-namespace --set prometheus.prometheusSpec.resources.limits.memory=2500Mi
	helm upgrade --install --namespace cattle-logging-system rancher-logging-crd rancher-charts/rancher-logging-crd --create-namespace --wait
	helm upgrade --install --namespace cattle-logging-system rancher-logging rancher-charts/rancher-logging --create-namespace
	helm upgrade --install --namespace istio-system rancher-kiali-server-crd rancher-charts/rancher-kiali-server-crd --create-namespace --wait
	helm upgrade --install --namespace istio-system rancher-istio rancher-charts/rancher-istio --create-namespace --set tracing.enabled=true
	helm upgrade --install --namespace longhorn-system longhorn-crd rancher-charts/longhorn-crd --create-namespace --wait
	helm upgrade --install --namespace longhorn-system longhorn rancher-charts/longhorn --create-namespace
	kubectl apply -f longhorn_monitoring/

install-sealed-secrets:
	helm upgrade --install --namespace kube-system sealed-secrets-controller stable/sealed-secrets  --version v1.10.3

install-cert-manager:
	kubectl create namespace istio-system || true
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.1.0 --set installCRDs=true --wait --create-namespace
	cat cert-manager/clusterissuer.yaml | envsubst | kubectl apply -f -
	cat cert-manager/credentials-secret.yaml | envsubst | kubectl apply -f -

install-external-dns:
	helm upgrade --install external-dns bitnami/external-dns --namespace=external-dns --version 4.5.1 -f external-dns/values.yaml --set digitalocean.apiToken=$(DIGITALOCEAN_TOKEN) --create-namespace

install-mysql-operator:
	kubectl create namespace mysql-operator || true
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
	kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/bookinfo/platform/kube/bookinfo.yaml
	kubectl apply -n bookinfo -f https://raw.githubusercontent.com/istio/istio/release-1.7/samples/bookinfo/networking/destination-rule-all.yaml
	kubectl apply -f bookinfo

install-rancher-demo:
	cat rancher-demo/deployment.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/service.yaml | envsubst | kubectl apply -f -
	cat rancher-demo/ingress.yaml | envsubst | kubectl apply -f -

install-loki:
	helm upgrade --install loki loki/loki --namespace loki --version 2.1.1 -f loki/values.yaml --create-namespace
	kubectl apply -f loki/datasource.yaml
	kubectl apply -f loki/logging-flow.yaml
	kubectl rollout restart deployment -n cattle-monitoring-system rancher-monitoring-grafana

install-rio:
	# rio install --email $(EMAIL)
install-argocd:
	kubectl create namespace argocd || true
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	cat argocd/ingress.yaml | envsubst | kubectl apply -f -

install-nexus:
	helm upgrade --install nexus oteemo/sonatype-nexus --namespace nexus --version 2.1.0 -f nexus/values.yaml --create-namespace

install-keycloak:
	helm upgrade --install keycloak codecentric/keycloak --namespace keycloak --version 9.0.1 -f keycloak/values.yaml --create-namespace

install-elk:
	kubectl create namespace logging || true
	kubectl apply -f elk/basic-auth.yaml
	helm upgrade --install elasticsearch elastic/elasticsearch --version 7.8.1 --namespace logging -f elk/elasticsearch/values.yaml
	helm upgrade --install kibana elastic/kibana --version 7.8.1 --namespace logging -f elk/kibana/values.yaml

install-weave-scope:
	kubectl create namespace weave-scope || true
	kubectl apply -f weave-scope/basic-auth.yaml
	cat weave-scope/values.yaml | envsubst | helm upgrade --install weave-scope  stable/weave-scope  --namespace weave-scope  --version 1.1.10 -f -

install-trow:
	kubectl create namespace trow || true
	kubectl apply -f trow/issuer.yaml
	helm upgrade --install -f trow/values.yaml trow trow/trow --namespace trow

install-harbor:
	mkdir -p exported-charts
	kubectl create namespace harbor || true
	helm chart pull registry.suse.com/harbor/harbor:1.5
	helm chart export registry.suse.com/harbor/harbor:1.5 -d ./exported-charts
	helm upgrade --install harbor ./exported-charts/harbor --namespace harbor -f harbor/harbor-values.yaml
	kubectl apply -f harbor/certificate.yaml

troubleshoot-network:
	kubectl apply -f network-debugging
	kubectl rollout status daemonset -n default overlaytest
	echo "=> Start network overlay test"; kubectl -n default get pods -l name=overlaytest -o jsonpath='{range .items[*]}{@.metadata.name}{" "}{@.spec.nodeName}{"\n"}{end}' | while read spod shost; do kubectl -n default get pods -l name=overlaytest -o jsonpath='{range .items[*]}{@.status.podIP}{" "}{@.spec.nodeName}{"\n"}{end}' | while read tip thost; do kubectl -n default --request-timeout='10s' exec $spod -- /bin/sh -c "ping -c2 $tip > /dev/null 2>&1"; RC=$?; if [ $RC -ne 0 ]; then echo $shost cannot reach $thost; fi; done; done; echo "=> End network overlay test"
