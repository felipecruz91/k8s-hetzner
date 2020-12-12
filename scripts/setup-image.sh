#!/bin/bash
set -x

sudo apt-get update \
  && sudo apt-get install -qy docker.io

sudo apt-get update \
  && sudo apt-get install -y apt-transport-https \
  && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" \
  | sudo tee -a /etc/apt/sources.list.d/kubernetes.list \
  && sudo apt-get update 

sudo apt-get update \
  && sudo apt-get install -yq \
  kubelet=1.19.5-00 \
  kubeadm=1.19.5-00 \
  kubernetes-cni \
  perl # --> shasum: command not found

sudo apt-mark hold kubelet kubeadm kubectl
