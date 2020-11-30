# Rancher setup behind HTTP proxy on AWS

This terraform example sets up Rancher in a private AWS Subnet that only has Internet connectivity through an HTTP Proxy.

The following resources will be set up:

* One VPC
* One public subnet with an Internet Gateway
* One private subnet without an Internet Gateway
* One proxy VM in the public subnet with the following tools installed
  * OpenVPN Server
  * Tinyproxy
  * Nginx
* A security group for the proxy VM that allows
  * Incoming SSH traffic from all networks (port 22)
  * Incoming VPN traffic from all networks to the OpenVPN server (port 1194)
  * Incoming HTTP and HTTPS traffic from all networks to the nginx (ports 80 and 443)
  * Outgoing HTTP and HTTPS traffic to the internet (ports 80 and 443)
  * Outgoing HTTP and HTTPS traffic to the ingress controller on cluster vms in the private subnet (ports 80 and 443)
  * Outgoing HTTPS traffic to the kubernetes apiserver on cluster vms in the private subnet (ports 6443)
  * Outgoing SSH traffic to the whole VPC (port 22)
  * Incoming traffic to a proxy from the whole VPC to tinyproxy (port 8888)
* 3 cluster VMs in the private subnet
* A security group for the cluster vms that allows
  * Incoming SSH trafic from the public subnet (port 22)
  * Incoming HTTPS traffic to the kubernetes apiserver from the public subnet (port 6443)
  * Incoming HTTP and HTTPS traffic to the ingress controller from the public subnet (ports 80 and 443)
  * Incoming and outgoing traffic on all ports between the cluster vms in the private subnet
  * Outgoing traffic to the tinyproxy in the public subnet (port 8888)
  
On the cluster VMs in the private subnet then

* apt will be configured to go through tinyproxy
* Docker will be installed
* The Docker daemon will be configured to pull images through tinyprox
* An RKE Kubernetes cluster will be created
* cert-manager will be installed with tinyproxy configured
* Rancher will be installed with tinyproxy configured
   