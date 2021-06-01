# Network policies

- Create deployment

```sh
kubectl apply -f deployment.yaml
```

- Call httpbin with curl from network-policy-test namespace

```sh
kubectl --namespace network-policy-test run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- Create network policy that forbids call

```sh
kubectl apply -f network-policy-allow-other-namespace.yaml
```

- See that connection can not be established

```sh
kubectl --namespace network-policy-test run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- label namespace

```sh
kubectl label namespace network-policy-test access=allowed
```

- See that connection works again

```sh
kubectl --namespace network-policy-test run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- remove label

```sh
kubectl label namespace network-policy-test access-
```

- See that connection can not be established

```sh
kubectl --namespace network-policy-test run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- Delete network policy that forbids call

```sh
kubectl delete -f network-policy-allow-other-namespace.yaml
```

- See that connection works again

```sh
kubectl --namespace network-policy-test run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- Create network policy that allows the call by pod label

```sh
kubectl apply -f network-policy-allow-pod-label.yaml
```

- See that connection does not work without lable

```sh
kubectl --namespace web-application run curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```

- See that connection works with label

```sh
kubectl --namespace web-application run curl -l app=curl --image=radial/busyboxplus:curl --restart=Never --rm -i --command curl -- http://httpbin.web-application:90 -v --connect-timeout 5
```