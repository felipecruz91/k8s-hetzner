#!/bin/bash
set -x

sudo kubeadm init --apiserver-advertise-address=10.0.1.5 --pod-network-cidr=192.168.0.0/16 --kubernetes-version stable-1.24

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "export KUBECONFIG=$HOME/.kube/config" | tee -a ~/.bashrc

source ~/.bashrc

#sudo mkdir -p /var/lib/weave
#head -c 16 /dev/urandom | shasum -a 256 | cut -d" " -f1 | sudo tee /var/lib/weave/weave-passwd

#kubectl create secret -n kube-system generic weave-passwd --from-file=/var/lib/weave/weave-passwd

#kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&password-secret=weave-passwd&env.IPALLOC_RANGE=192.168.0.0/24"

# Install calico CNI
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/tigera-operator.yaml
curl https://raw.githubusercontent.com/projectcalico/calico/v3.24.5/manifests/custom-resources.yaml -O
kubectl create -f custom-resources.yaml
