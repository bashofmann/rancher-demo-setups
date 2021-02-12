# downstream-harvester-do

Creates a downstream cluster on digital ocean, with nested virtualization and installs harvester.

## Installation

Before applying the module run

```
touch out/kube_conig_demo.yaml
```

Run terraform

```
terraform init
terraform apply
```

## Harvester login credentials

admin/password

## Images

* https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
* https://download.opensuse.org/tumbleweed/iso/openSUSE-MicroOS-DVD-x86_64-Current.iso

## Connect to vms via ssh

Add SSH key before creating a VM!

```
ssh -J root@KUBERNETS_NODE_IP ubuntu@VM_IP
```

## cloud-config to set user password

```
#cloud-config
password: password
chpasswd: {expire: false}
ssh_pwauth: true
```

## Cleanup

```
terraform destroy
```