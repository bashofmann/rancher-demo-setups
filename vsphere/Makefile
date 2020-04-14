install-rancher:
	kubectl version
	kubectl create namespace cert-manager || true
	kubectl create namespace cattle-system || true
	helm repo add jetstack https://charts.jetstack.io
	helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
	helm repo update
	echo "Installing cert-manager $(CERT_MANAGER_VERSION)"
	helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager --version $(CERT_MANAGER_VERSION) --set installCRDs=true --wait
	kubectl apply -f certificate
	echo "Installing Rancher $(RANCHER_VERSION)"
	helm upgrade --install rancher rancher-latest/rancher --namespace cattle-system --version $(RANCHER_VERSION) --set ingress.tls.source=secret --set hostname=$(RANCHER_HOSTNAME) --wait